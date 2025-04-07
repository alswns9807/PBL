from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from datetime import datetime

from app.database import SessionLocal
from app.models.reading_records import UserBook
from app.models.book import Book

from typing import List
from app.schemas.book import BookOut  

router = APIRouter(prefix="/statistics", tags=["Statistics"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/{user_id}")
def get_user_statistics(user_id: int, year: int = Query(default=datetime.now().year), db: Session = Depends(get_db)):
    # 1. 장르 비율
    genre_counts = (
        db.query(Book.genre, func.count(Book.genre))
        .join(UserBook, Book.isbn == UserBook.isbn)
        .filter(UserBook.user_id == user_id)
        .filter(extract("year", UserBook.end_date) == year)
        .group_by(Book.genre)
        .all()
    )
    total_genre = sum(count for _, count in genre_counts)
    genre_ratio = [
        {
            "genre": genre,
            "count": count,
            "percentage": round((count / total_genre) * 100, 1) if total_genre else 0
        }
        for genre, count in genre_counts
    ]

    # 2. 월별 독서량
    monthly_read_count = [
        {
            "month": i,
            "count": db.query(func.count(UserBook.user_book_id))
                .filter(UserBook.user_id == user_id)
                .filter(extract("year", UserBook.end_date) == year)
                .filter(extract("month", UserBook.end_date) == i)
                .scalar()
        }
        for i in range(1, 13)
    ]

    # 3. 월별 페이지 수
    monthly_page_count = [
        {
            "month": i,
            "pages": db.query(func.coalesce(func.sum(UserBook.progress), 0))
                .filter(UserBook.user_id == user_id)
                .filter(extract("year", UserBook.end_date) == year)
                .filter(extract("month", UserBook.end_date) == i)
                .scalar()
        }
        for i in range(1, 13)
    ]

    # 4. 가장 많이 읽은 장르
    favorite_genre = max(genre_counts, key=lambda x: x[1], default=None)
    favorite_genre = {"name": favorite_genre[0], "count": favorite_genre[1]} if favorite_genre else None

    # 5. 가장 오래 걸린 책
    longest = (
        db.query(UserBook, Book.title, func.age(UserBook.end_date, UserBook.start_date).label("duration"))
        .join(Book, Book.isbn == UserBook.isbn)
        .filter(UserBook.user_id == user_id)
        .filter(UserBook.start_date != None, UserBook.end_date != None)
        .filter(extract("year", UserBook.end_date) == year)
        .order_by(func.age(UserBook.end_date, UserBook.start_date).desc())
        .first()
    )
    longest_reading_book = {
        "title": longest.title,
        "days": longest.duration.days
    } if longest else None

    # 6. 가장 많이 읽은 책
    most_read = (
        db.query(Book.title, func.count(UserBook.isbn).label("cnt"))
        .join(Book, Book.isbn == UserBook.isbn)
        .filter(UserBook.user_id == user_id)
        .filter(extract("year", UserBook.end_date) == year)
        .group_by(UserBook.isbn, Book.title)
        .order_by(func.count(UserBook.isbn).desc())
        .first()
    )
    most_read_book = {
        "title": most_read.title,
        "count": most_read.cnt
    } if most_read else None

    return {
        "year": year,
        "genre_ratio": genre_ratio,
        "monthly_read_count": monthly_read_count,
        "monthly_page_count": monthly_page_count,
        "favorite_genre": favorite_genre,
        "longest_reading_book": longest_reading_book,
        "most_read_book": most_read_book
    }

@router.get("/{user_id}/genre/{genre}", response_model=List[BookOut])
def get_books_by_genre(user_id: int, genre: str, db: Session = Depends(get_db)):

    books = (
        db.query(Book)
        .join(UserBook, Book.isbn == UserBook.isbn)
        .filter(UserBook.user_id == user_id)
        .filter(Book.genre == genre)
        .order_by(UserBook.created_at.desc())
        .all()
    )

    if not books:
        raise HTTPException(status_code=404, detail=f"No books found for genre '{genre}'.")

    return books