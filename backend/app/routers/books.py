from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.book import Book
from app.models.genre import Genre, book_genres_table
from app.schemas.book import BookCreate, BookOut
from app.services.aladin_api import search_books_from_aladin, fetch_book_from_aladin
import asyncio

router = APIRouter(prefix="/books", tags=["Books"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=BookOut)
def create_book(book_data: BookCreate, db: Session = Depends(get_db)):
    # ISBN 중복 체크
    existing = db.query(Book).filter(Book.isbn == book_data.isbn).first()
    if existing:
        raise HTTPException(status_code=400, detail="이미 등록된 책입니다.")

    # 장르 처리
    genre_objects = []
    for genre_name in book_data.genres:
        genre = db.query(Genre).filter(Genre.name == genre_name).first()
        if not genre:
            genre = Genre(name=genre_name)
            db.add(genre)
            db.flush()  # ID 확보
        genre_objects.append(genre)

    # Book 생성
    new_book = Book(
        isbn=book_data.isbn,
        title=book_data.title,
        author=book_data.author,
        publisher=book_data.publisher,
        published_date=book_data.published_date,
        cover_image=book_data.cover_image,
        description=book_data.description,
        page_count=book_data.page_count,
        genres=genre_objects  # 다대다 관계 연결
    )

    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    return new_book

@router.get("/", response_model=list[BookOut])
def get_books(db: Session = Depends(get_db)):
    books = db.query(Book).all()
    return [BookOut.from_orm_with_genres(b) for b in books]

@router.get("/search")
async def search_books(q: str):
    raw_results = await search_books_from_aladin(q)

    async def enrich_item(item):
        isbn = item.get("isbn13")
        if not isbn:
            return None

        detailed = await fetch_book_from_aladin(isbn)
        return {
            "title": item.get("title"),
            "isbn": isbn,
            "author": item.get("author"),
            "publisher": item.get("publisher"),
            "cover": item.get("cover"),
            "page_count": detailed.get("page_count") if detailed else None
        }

    books = await asyncio.gather(*[enrich_item(item) for item in raw_results])
    return [b for b in books if b]

@router.post("/fetch", response_model=BookOut)
async def fetch_book(isbn: str, db: Session = Depends(get_db)):
    existing = db.query(Book).filter(Book.isbn == isbn).first()
    if existing:
        return BookOut.from_orm_with_genres(existing)

    base_data = await fetch_book_from_aladin(isbn)
    if not base_data:
        raise HTTPException(status_code=404, detail="알라딘에서 책 정보를 찾을 수 없습니다.")
    if not base_data.get("page_count"):
        raise HTTPException(status_code=422, detail="쪽수 정보를 가져올 수 없습니다.")

    # 장르 처리
    genre_objects = []
    for genre_name in base_data.get("genres", []):
        genre = db.query(Genre).filter(Genre.name == genre_name).first()
        if not genre:
            genre = Genre(name=genre_name)
            db.add(genre)
            db.flush()
        genre_objects.append(genre)

    book = Book(
        isbn=base_data["isbn"],
        title=base_data["title"],
        author=base_data["author"],
        publisher=base_data.get("publisher"),
        published_date=base_data.get("published_date"),
        cover_image=base_data.get("cover_image"),
        description=base_data.get("description"),
        page_count=base_data.get("page_count"),
        genres=genre_objects
    )

    db.add(book)
    db.commit()
    db.refresh(book)
    return BookOut.from_orm_with_genres(book)
