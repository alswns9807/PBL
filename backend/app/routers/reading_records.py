from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.reading_records import UserBook
from app.schemas.reading_records import UserBookCreate, UserBookOut, UserBookUpdate
from app.models.note import Note
from app.schemas.reading_records import UserBookDetail

router = APIRouter(prefix="/reading", tags=["Reading Records"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

#사용자 책 등록
@router.post("/", response_model=UserBookOut)
def create_user_book(record: UserBookCreate, db: Session = Depends(get_db)):
    # ✅ 읽을 예정
    if record.status == "읽을 예정":
        if any([
            record.start_date, record.end_date,
            record.rating is not None, record.review, record.progress
        ]):
            raise HTTPException(400, detail="읽을 예정 상태에서는 기대평 외의 정보는 입력할 수 없습니다.")

    # ✅ 읽는 중
    elif record.status == "읽는 중":
        if not record.start_date:
            raise HTTPException(400, detail="읽는 중 상태에서는 시작일이 필요합니다.")
        if any([
            record.end_date, record.rating is not None, record.review
        ]):
            raise HTTPException(400, detail="읽는 중 상태에서는 종료일, 별점, 리뷰는 입력할 수 없습니다.")

    # ✅ 읽음
    elif record.status == "읽음":
        if not all([record.start_date, record.end_date]) or record.rating is None:
            raise HTTPException(400, detail="읽음 상태에서는 시작일, 종료일, 별점이 필수입니다.")
        if record.progress or record.expectation:
            raise HTTPException(400, detail="읽음 상태에서는 진행도, 기대평은 입력할 수 없습니다.")

    else:
        raise HTTPException(400, detail="유효하지 않은 status 값입니다.")

    # ✅ 등록 처리
    new_record = UserBook(**record.dict())
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    return new_record



#모든 사용자에게 등록된 책 조회
@router.get("/", response_model=list[UserBookOut])
def get_all_records(db: Session = Depends(get_db)):
    return db.query(UserBook).all()

#특정 사용자 등록된 책 조회
@router.get("/user/{user_id}", response_model=list[UserBookOut])
def get_user_books(user_id: int, db: Session = Depends(get_db)):
    records = (
        db.query(UserBook)
        .filter(UserBook.user_id == user_id)
        .order_by(UserBook.created_at.desc())  #등록일 기준 정렬
        .all()
    )
    return records

#특정 사용자 등록된 책의 메모들 조회
@router.get("/{user_book_id}", response_model=UserBookDetail)
def get_user_book_detail(user_book_id: int, db: Session = Depends(get_db)):
    record = db.query(UserBook).filter(UserBook.user_book_id == user_book_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="기록을 찾을 수 없습니다.")

    notes = db.query(Note).filter(Note.user_book_id == user_book_id).order_by(Note.created_at).all()

    # notes를 붙여서 반환
    result = UserBookDetail(**record.__dict__, notes=notes)
    return result

#사용자 등록 책 삭제
@router.delete("/{user_book_id}")
def delete_user_book(user_book_id: int, db: Session = Depends(get_db)):
    record = db.query(UserBook).filter(UserBook.user_book_id == user_book_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="기록이 존재하지 않습니다.")

    # 연결된 메모도 같이 삭제
    db.query(Note).filter(Note.user_book_id == user_book_id).delete()

    db.delete(record)
    db.commit()

    return {"message": "해당 독서 기록과 메모가 삭제되었습니다."}

@router.put("/{user_book_id}", response_model=UserBookOut)
def update_user_book(
    user_book_id: int,
    record: UserBookUpdate,
    db: Session = Depends(get_db)
):
    existing = db.query(UserBook).filter(UserBook.user_book_id == user_book_id).first()
    if not existing:
        raise HTTPException(404, detail="해당 독서 기록을 찾을 수 없습니다.")

    # 현재 상태 or 수정 요청의 상태 확인
    new_status = record.status or existing.status

    # ✅ 상태별 유효성 검사
    if new_status == "읽을 예정":
        if any([
            record.start_date, record.end_date,
            record.rating is not None, record.review, record.progress
        ]):
            raise HTTPException(400, detail="읽을 예정 상태에서는 기대평 외의 정보는 입력할 수 없습니다.")

    elif new_status == "읽는 중":
        if record.start_date is None and existing.start_date is None:
            raise HTTPException(400, detail="읽는 중 상태에서는 시작일(start_date)이 필요합니다.")
        if any([
            record.end_date, record.rating is not None, record.review
        ]):
            raise HTTPException(400, detail="읽는 중 상태에서는 종료일, 별점, 리뷰는 입력할 수 없습니다.")

    elif new_status == "읽음":
        final_start = record.start_date or existing.start_date
        final_end = record.end_date or existing.end_date
        final_rating = record.rating if record.rating is not None else existing.rating

        if not all([final_start, final_end]) or final_rating is None:
            raise HTTPException(400, detail="읽음 상태에서는 시작일, 종료일, 별점이 필수입니다.")

        if record.progress or record.expectation:
            raise HTTPException(400, detail="읽음 상태에서는 진행도, 기대평은 입력할 수 없습니다.")

    else:
        raise HTTPException(400, detail="유효하지 않은 status 값입니다.")

    # ✅ 값 반영
    for key, value in record.dict(exclude_unset=True).items():
        setattr(existing, key, value)

    db.commit()
    db.refresh(existing)
    return existing

