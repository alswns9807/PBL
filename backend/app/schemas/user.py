from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    user_name: str
    email: EmailStr
    profile_picture: Optional[str] = None
    bio: Optional[str] = None

class UserOut(BaseModel):
    user_id: int
    user_name: str
    email: EmailStr
    profile_picture: Optional[str]
    bio: Optional[str]
    create_at: datetime

    class Config:
        from_attributes = True  # SQLAlchemy 모델 -> Pydantic 변환 허용
