from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.book import Book
from app.schemas.book import BookCreate, BookOut
from app.services.aladin_api import search_books_from_aladin, fetch_book_from_aladin


router = APIRouter(prefix="/books", tags=["Books"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=BookOut)
def create_book(book: BookCreate, db: Session = Depends(get_db)):
    new_book = Book(**book.dict())
    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    return new_book

@router.get("/", response_model=list[BookOut])
def get_books(db: Session = Depends(get_db)):
    return db.query(Book).all()

@router.get("/search")
async def search_books(q: str):
    raw_results = await search_books_from_aladin(q)

    books = []

    for item in raw_results:
        isbn = item.get("isbn13")

        # → ISBN이 있으면 LookUp으로 다시 요청
        detailed = await fetch_book_from_aladin(isbn) if isbn else None

        books.append({
            "title": item.get("title"),
            "isbn": isbn,
            "author": item.get("author"),
            "publisher": item.get("publisher"),
            "cover": item.get("cover"),
            "page_count": detailed.get("page_count") if detailed else None
        })

    return books

@router.post("/fetch", response_model=BookOut)
async def fetch_book(isbn: str, db: Session = Depends(get_db)):
    # 기존 등록 여부 확인
    existing = db.query(Book).filter(Book.isbn == isbn).first()
    if existing:
        return existing

    # 1. 알라딘 API
    base_data = await fetch_book_from_aladin(isbn)
    if not base_data:
        raise HTTPException(status_code=404, detail="알라딘에서 책 정보를 찾을 수 없습니다.")

    # 2. page_count 없음 → 예외 처리
    if not base_data.get("page_count"):
        raise HTTPException(status_code=422, detail="쪽수 정보를 가져올 수 없습니다.")

    # 3. 저장
    book = Book(**base_data)
    db.add(book)
    db.commit()
    db.refresh(book)
    return book

