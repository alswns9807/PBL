from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.reading_records import UserBook
from app.models.book import Book, book_genres_table
from app.models.genre import Genre
from app.models.user import User

def get_most_read_genre(user_id: int, db: Session):
    genre_counts = (
        db.query(Genre.name, func.count().label("count"))
        .join(book_genres_table, Genre.genre_id == book_genres_table.c.genre_id)
        .join(Book, Book.isbn == book_genres_table.c.isbn)
        .join(UserBook, UserBook.isbn == Book.isbn)
        .filter(UserBook.user_id == user_id)
        .group_by(Genre.name)
        .order_by(func.count().desc())
        .all()
    )
    return genre_counts[0][0] if genre_counts else None

def recommend_books_by_genre(user_id: int, db: Session):
    favorite_genre = get_most_read_genre(user_id, db)
    if not favorite_genre:
        return []

    subquery = db.query(UserBook.isbn).filter(UserBook.user_id == user_id).subquery()

    results = (
        db.query(Book, func.count(UserBook.user_id).label("registered_count"))
        .join(book_genres_table, Book.isbn == book_genres_table.c.isbn)
        .join(Genre, Genre.genre_id == book_genres_table.c.genre_id)
        .outerjoin(UserBook, Book.isbn == UserBook.isbn)
        .filter(Genre.name == favorite_genre)
        .filter(~Book.isbn.in_(subquery))
        .group_by(Book.isbn)
        .order_by(func.count(UserBook.user_id).desc())
        .limit(10)
        .all()
    )

    return [
        {
            "isbn": book.isbn,
            "title": book.title,
            "author": book.author,
            "publisher": book.publisher,
            "cover_image": book.cover_image,
            "registered_count": count
        }
        for book, count in results
    ]