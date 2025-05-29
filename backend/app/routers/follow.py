# app/routers/follow.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.follow import Follow
from app.models.user import User
from app.schemas.follow import FollowCreate, FollowResponse, FollowUserInfo, RecommendedBook, FollowRecommendationResponse
from app.models.reading_records import UserBook
from app.models.book import Book
from app.models.note import Note

router = APIRouter(prefix="/follows", tags=["Follows"])

@router.post("/", response_model=FollowResponse)
def follow_user(request: FollowCreate, db: Session = Depends(get_db)):
    if request.follower_id == request.followed_id:
        raise HTTPException(status_code=400, detail="자기 자신을 팔로우할 수 없습니다.")

    existing = db.query(Follow).filter(
        Follow.follower_id == request.follower_id,
        Follow.followed_id == request.followed_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="이미 팔로우한 사용자입니다.")

    follow = Follow(**request.dict())
    db.add(follow)
    db.commit()
    db.refresh(follow)
    return follow

@router.delete("/", status_code=204)
def unfollow_user(follower_id: str = Query(...), followed_id: str = Query(...), db: Session = Depends(get_db)):
    relation = db.query(Follow).filter(
        Follow.follower_id == follower_id,
        Follow.followed_id == followed_id
    ).first()
    if not relation:
        raise HTTPException(status_code=404, detail="팔로우 관계가 존재하지 않습니다.")
    db.delete(relation)
    db.commit()
    return

@router.get("/followers", response_model=list[FollowUserInfo])
def get_followers(user_id: str = Query(...), db: Session = Depends(get_db)):
    follows = db.query(Follow).filter(Follow.followed_id == user_id).all()
    return [FollowUserInfo.from_orm(f.follower) for f in follows]

@router.get("/following", response_model=list[FollowUserInfo])
def get_following(user_id: str = Query(...), db: Session = Depends(get_db)):
    follows = db.query(Follow).filter(Follow.follower_id == user_id).all()
    return [FollowUserInfo.from_orm(f.followed) for f in follows]

@router.get("/{followed_user_id}/recommendations", response_model=FollowRecommendationResponse)
def get_followed_user_recommendations(
    followed_user_id: str,
    current_user_id: str = Query(...),  # 요청자
    db: Session = Depends(get_db)
):
    # 유저 존재 확인
    followed_user = db.query(User).filter(User.user_id == followed_user_id).first()
    if not followed_user:
        raise HTTPException(status_code=404, detail="유저 정보 없음")

    # 요청자가 팔로우한 사람인지 확인 (보안 목적)
    follow_relation = db.query(Follow).filter(
        Follow.follower_id == current_user_id,
        Follow.followed_id == followed_user_id
    ).first()
    if not follow_relation:
        raise HTTPException(status_code=403, detail="팔로우한 유저가 아닙니다.")

    # 사용자가 아직 등록하지 않은 책 중 추천 도서 필터링
    user_book_isbns = db.query(UserBook.isbn).filter(UserBook.user_id == current_user_id).subquery()

    records = (
        db.query(UserBook)
        .filter(
            UserBook.user_id == followed_user_id,
            UserBook.is_public == True,
            UserBook.rating >= 4,
            ~UserBook.isbn.in_(user_book_isbns)
        )
        .join(Book)
        .outerjoin(Note, Note.user_book_id == UserBook.user_book_id)
        .order_by(UserBook.rating.desc())
        .limit(10)
        .all()
    )

    # 응답 구성
    recommended_books = []
    for record in records:
        content = ""

        if record.notes:
            latest_note = sorted(record.notes, key=lambda n: n.created_at, reverse=True)[0]
            content = latest_note.content
        elif record.review:
            content = record.review

        recommended_books.append(
            RecommendedBook(
                isbn=record.book.isbn,
                title=record.book.title,
                cover_image=record.book.cover_image,
                rating=record.rating,
                review=record.review or "",
                note=content
            )
        )

    return FollowRecommendationResponse(
        followed_user_id=followed_user_id,
        followed_user_name=followed_user.user_name,
        recommended_books=[book.model_dump() for book in recommended_books]
    )
