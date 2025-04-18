from pydantic import BaseModel
from typing import List, Optional


class GenreRatio(BaseModel):
    genre: str
    count: int
    percentage: float


class MonthlyReadCount(BaseModel):
    month: int
    count: int


class MonthlyPageCount(BaseModel):
    month: int
    pages: int


class FavoriteGenre(BaseModel):
    name: Optional[str]
    count: int


class LongestReadingBook(BaseModel):
    title: str
    days: int


class MostReadBook(BaseModel):
    title: str
    count: int


class UserStatisticsResponse(BaseModel):
    year: int
    genre_ratio: List[GenreRatio]
    monthly_read_count: List[MonthlyReadCount]
    monthly_page_count: List[MonthlyPageCount]
    favorite_genre: FavoriteGenre
    longest_reading_book: LongestReadingBook
    most_read_book: MostReadBook

class BookByGenreOut(BaseModel):
    title: str
    isbn: str
    cover_image: Optional[str] = None

    class Config:
        orm_mode = True