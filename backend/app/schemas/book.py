from pydantic import BaseModel
from datetime import date

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

class BookCreate(BookBase):
    pass  

class BookOut(BookBase):
    class Config:
        from_attributes = True
