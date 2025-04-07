from pydantic import BaseModel
from datetime import date
from typing import Optional

class BookBase(BaseModel):
    isbn: str 
    title: str
    author: str
    publisher: str | None = None
    published_date: date | None = None
    cover_image: str | None = None
    description: str | None = None
    genre: str | None = None
    page_count: int | None = None

class BookCreate(BaseModel):
    title: str
    author: str
    publisher: Optional[str]
    published_date: Optional[date]
    cover_image: Optional[str]
    description: Optional[str]
    genre: Optional[str]
    page_count: int 
    isbn: str


class BookOut(BookBase):
    class Config:
        from_attributes = True
