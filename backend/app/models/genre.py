from sqlalchemy import Column, Integer, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from app.database import Base

# 중간 테이블: 책 <-> 장르 다대다 관계
book_genres_table = Table(
    "book_genres",
    Base.metadata,
    Column("isbn", String, ForeignKey("books.isbn"), primary_key=True),
    Column("genre_id", Integer, ForeignKey("genres.genre_id"), primary_key=True)
)

class Genre(Base):
    __tablename__ = "genres"

    genre_id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)

    books = relationship("Book", secondary=book_genres_table, back_populates="genres")
