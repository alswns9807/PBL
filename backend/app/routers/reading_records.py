from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.reading_records import UserBook
from app.schemas.reading_records import UserBookCreate, UserBookOut
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