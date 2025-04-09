from pydantic import BaseModel
from datetime import date
from typing import Optional, List

class BookBase(BaseModel):
    isbn: str
    title: str
    author: str
    publisher: Optional[str] = None
    published_date: Optional[date] = None
    cover_image: Optional[str] = None
    description: Optional[str] = None
    genres: List[str] = []  # 장르를 리스트로 변경
    page_count: Optional[int] = None

class BookCreate(BaseModel):
    title: str
    author: str
    publisher: Optional[str]
    published_date: Optional[date]
    cover_image: Optional[str]
    description: Optional[str]
    genres: Optional[List[str]] = []  # 장르를 리스트로 변경
    page_count: int
    isbn: str

class BookOut(BookBase):
    genres: List[str]  # 명시적으로 재정의

    class Config:
        from_attributes = True

    @staticmethod
    def from_orm_with_genres(book_orm):
        return BookOut(
            isbn=book_orm.isbn,
            title=book_orm.title,
            author=book_orm.author,
            publisher=book_orm.publisher,
            published_date=book_orm.published_date,
            cover_image=book_orm.cover_image,
            description=book_orm.description,
            genres=[genre.name for genre in book_orm.genres],  # Genre → str
            page_count=book_orm.page_count
        )

