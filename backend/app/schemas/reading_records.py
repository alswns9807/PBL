from pydantic import BaseModel
from typing import Optional
from datetime import date
from datetime import datetime
from app.schemas.note import NoteOut

class UserBookBase(BaseModel):
    status: str  # 읽음 / 읽는 중 / 읽을 예정
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    rating: Optional[int] = None
    review: Optional[str] = None
    progress: Optional[int] = None

class UserBookCreate(UserBookBase):
    user_id: int
    isbn: str

class UserBookOut(UserBookBase):
    user_book_id: int
    user_id: int
    isbn: str
    created_at: datetime

    class Config:
        from_attributes = True
        
class UserBookDetail(UserBookOut):
    notes: list[NoteOut] = []
