from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.follow import Follow
from app.schemas.user import UserCreate, UserOut

router = APIRouter(prefix="/users", tags=["Users"])

# 사용자 등록
@router.post("/", response_model=UserOut)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="이미 등록된 이메일입니다.")

    new_user = User(**user.dict())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

# 전체 사용자 조회 (검색 없을 시 전체 반환)
@router.get("/", response_model=List[UserOut])
def get_users(
    keyword: Optional[str] = Query(None, description="이름 또는 이메일로 검색"),
    db: Session = Depends(get_db)
):
    query = db.query(User)
    if keyword:
        like = f"%{keyword}%"
        query = query.filter((User.user_name.ilike(like)) | (User.email.ilike(like)))
    return query.all()

@router.get("/{user_id}", response_model=UserOut)
def get_user_detail(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    followers_count = db.query(Follow).filter(Follow.followed_id == user_id).count()
    following_count = db.query(Follow).filter(Follow.follower_id == user_id).count()

    return UserOut(
        user_id=user.user_id,
        user_name=user.user_name,
        email=user.email,
        profile_picture=user.profile_picture,
        bio=user.bio,
        create_at=user.create_at,
        update_at=user.update_at,
        followers_count=followers_count,
        following_count=following_count
    )