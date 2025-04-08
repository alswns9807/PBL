from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserOut

router = APIRouter(prefix="/users", tags=["Users"])

# ✅ 사용자 등록
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

# ✅ 전체 사용자 조회 (검색 없을 시 전체 반환)
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