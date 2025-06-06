from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime
from app.schemas.note import NoteOut

class UserBookBase(BaseModel):
    status: str = Field(..., example="읽는 중")
    start_date: Optional[date] = Field(None, example=None)
    end_date: Optional[date] = Field(None, example=None)
    rating: Optional[int] = Field(None, example=None)
    review: Optional[str] = Field(None, example=None)
    progress: Optional[int] = Field(None, example=None)
    expectation: Optional[str] = Field(None, example=None)

class UserBookCreate(UserBookBase):
    user_id: str = Field(..., example=1)
    isbn: str = Field(..., example="9788956055461")
    is_public: Optional[bool] = Field(default=True, example=True)
    note_content: Optional[str] = None
    
    class Config:
        schema_extra = {
            "example": {
                "status": "읽는 중",
                "start_date": "2025-04-01",
                "progress": 50,
                "user_id": "A1213",
                "isbn": "9788956055461",
                "is_public":True
            }
        }

class UserBookOut(UserBookBase):
    user_book_id: int
    user_id: str
    isbn: str
    created_at: datetime
    is_public: bool

    class Config:
        from_attributes = True

class UserBookDetail(UserBookOut):
    notes: list[NoteOut] = []

class UserBookUpdate(BaseModel):
    status: Optional[str] = Field(None, example="읽음")
    start_date: Optional[date] = Field(None, example=None)
    end_date: Optional[date] = Field(None, example=None)
    progress: Optional[int] = Field(None, example=None)
    rating: Optional[int] = Field(None, example=None)
    review: Optional[str] = Field(None, example=None)
    expectation: Optional[str] = Field(None, example=None)
    is_public: Optional[bool] = Field(None, example=True)
    
    class Config:
        schema_extra = {
            "example": {
                "status": "읽음",
                "start_date": "2025-04-01",
                "end_date": "2025-04-05",
                "rating": 5,
                "review": "재미있게 읽었어요!",
                "is_public":True
            }
        }
