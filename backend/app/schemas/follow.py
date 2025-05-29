# schemas/follow.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class FollowCreate(BaseModel):
    follower_id: str
    followed_id: str

class FollowResponse(BaseModel):
    id: int
    follower_id: str
    followed_id: str
    followed_at: datetime

    class Config:
        from_attributes = True

class FollowUserInfo(BaseModel):
    user_id: str
    user_name: str
    email: str

    class Config:
        from_attributes = True

# 추천 도서용 스키마
class RecommendedBook(BaseModel):
    isbn: str
    title: str
    cover_image: Optional[str] = None
    rating: int
    review: str
    note: Optional[str] = None

    class Config:
        from_attributes = True

class FollowRecommendationResponse(BaseModel):
    followed_user_id: str
    followed_user_name: str
    recommended_books: List[RecommendedBook]

    class Config:
        from_attributes = True