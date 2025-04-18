from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime
from collections import Counter, defaultdict

from app.database import get_db
from app.models.reading_records import UserBook
from app.models.book import Book
from app.models.genre import Genre
from app.models.book import book_genres_table
from app.schemas.statistics import (
    UserStatisticsResponse,
    GenreRatio,
    MonthlyReadCount,
    MonthlyPageCount,
    FavoriteGenre,
    LongestReadingBook,
    MostReadBook,
    BookByGenreOut
)

router = APIRouter(
    prefix="/statistics",
    tags=["Statistics"]
)


@router.get("/user", response_model=UserStatisticsResponse)
def get_user_statistics(user_id: int = Query(...), year: int = Query(datetime.now().year), db: Session = Depends(get_db)):
    # 1. 해당 유저의 연도별 독서 기록 가져오기
    records = db.query(UserBook).filter(
        UserBook.user_id == user_id,
        UserBook.status == "읽음",
        UserBook.end_date != None,
        func.extract('year', UserBook.end_date) == year
    ).all()

    if not records:
        return UserStatisticsResponse(
            year=year,
            genre_ratio=[],
            monthly_read_count=[MonthlyReadCount(month=i, count=0) for i in range(1, 13)],
            monthly_page_count=[MonthlyPageCount(month=i, pages=0) for i in range(1, 13)],
            favorite_genre=FavoriteGenre(name=None, count=0),
            longest_reading_book=LongestReadingBook(title="", days=0),
            most_read_book=MostReadBook(title="", count=0)
        )

    # 2. 월별 통계 계산
    monthly_read_counter = Counter()
    monthly_page_counter = Counter()
    genre_counter = Counter()
    book_counter = Counter()
    longest_book = {"title": "", "days": 0}

    for record in records:
        if record.end_date:
            month = record.end_date.month
            monthly_read_counter[month] += 1

        # 책 기본정보
        book = db.query(Book).filter(Book.isbn == record.isbn).first()
        if book:
            # 페이지 수 누적
            monthly_page_counter[record.end_date.month] += book.page_count or 0

            # 책 읽은 횟수 누적
            book_counter[book.title] += 1

            # 책 장르 집계
            genres = (
                db.query(Genre.name)
                .join(book_genres_table, Genre.genre_id == book_genres_table.c.genre_id)
                .filter(book_genres_table.c.isbn == book.isbn)
                .all()
            )
            for genre in genres:
                genre_counter[genre.name] += 1

        # 가장 오래 읽은 책 계산
        if record.start_date and record.end_date:
            days = (record.end_date - record.start_date).days
            if days > longest_book["days"]:
                longest_book["title"] = book.title if book else ""
                longest_book["days"] = days

    # 3. 결과 포맷 변환
    total_genre_count = sum(genre_counter.values())

    genre_ratio = [
        GenreRatio(
            genre=genre,
            count=count,
            percentage=round((count / total_genre_count) * 100, 1)
        )
        for genre, count in genre_counter.items()
    ]

    monthly_read_count = [MonthlyReadCount(month=i, count=monthly_read_counter.get(i, 0)) for i in range(1, 13)]
    monthly_page_count = [MonthlyPageCount(month=i, pages=monthly_page_counter.get(i, 0)) for i in range(1, 13)]

    favorite_genre = (
        FavoriteGenre(name=genre_ratio[0].genre, count=genre_ratio[0].count)
        if genre_ratio else FavoriteGenre(name=None, count=0)
    )

    most_read_book = max(book_counter.items(), key=lambda x: x[1], default=("", 0))

    return UserStatisticsResponse(
        year=year,
        genre_ratio=genre_ratio,
        monthly_read_count=monthly_read_count,
        monthly_page_count=monthly_page_count,
        favorite_genre=favorite_genre,
        longest_reading_book=LongestReadingBook(title=longest_book["title"], days=longest_book["days"]),
        most_read_book=MostReadBook(title=most_read_book[0], count=most_read_book[1])
    )


@router.get("/{user_id}/books-by-genre", response_model=list[BookByGenreOut])
def get_books_by_genre(user_id: int, genre: str, db: Session = Depends(get_db)):
    books = (
        db.query(Book)
        .join(UserBook, UserBook.isbn == Book.isbn)
        .join(book_genres_table, book_genres_table.c.isbn == Book.isbn)
        .join(Genre, Genre.genre_id == book_genres_table.c.genre_id)
        .filter(
            UserBook.user_id == user_id,
            UserBook.status == "읽음",
            Genre.name == genre
        )
        .distinct()
        .all()
    )

    return books
