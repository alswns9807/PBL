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
        .limit(20)
        .all()
    )

    return [
        {
            "isbn": book.isbn,
            "title": book.title,
            "author": book.author,
            "publisher": book.publisher,
            "cover_image": book.cover_image,
            "registered_count": count,
            "reason": f"당신이 가장 많이 읽은 장르인 '{favorite_genre}' 기반 추천"
        }
        for book, count in results
    ]

def unified_recommendation(user_id: int, db: Session, top_k: int = 10):
    from app.services.recommendation_ai_service import get_ai_recommendations

    max_ai = 7
    max_genre = top_k - max_ai

    # AI 기반 추천
    ai_recs = get_ai_recommendations(db, user_id, top_k=max_ai)
    seen_isbns = {book['isbn'] for book in ai_recs}

    # 장르 기반 추천
    genre_recs = recommend_books_by_genre(user_id, db)
    genre_added = 0
    for book in genre_recs:
        if book['isbn'] not in seen_isbns and len(ai_recs) < top_k:
            ai_recs.append(book)
            seen_isbns.add(book['isbn'])
            genre_added += 1
        if genre_added >= max_genre:
            break

    return ai_recs

