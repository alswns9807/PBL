from sqlalchemy import Column, Integer, String, Date, Text
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.genre import book_genres_table  # ✅ 중간 테이블 import

class Book(Base):
    __tablename__ = "books"

    isbn = Column(String(20), primary_key=True, index=True)
    title = Column(String(100), nullable=False)
    author = Column(String(50), nullable=False)
    publisher = Column(String(50))
    published_date = Column(Date)
    cover_image = Column(String(255))
    description = Column(Text)
    page_count = Column(Integer)

    # ✅ 기존 genre(str) 제거하고, 다대다 관계로 변경
    genres = relationship("Genre", secondary=book_genres_table, back_populates="books")
