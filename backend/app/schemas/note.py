from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NoteBase(BaseModel):
    content: str

class NoteCreate(NoteBase):
    user_book_id: int

class NoteOut(NoteBase):
    note_id: int
    user_book_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
