from sqlalchemy import Column, Integer, String, Date, Text, ForeignKey,Boolean, DateTime
from datetime import datetime
from app.database import Base
from sqlalchemy.orm import relationship
from app.models.book import Book

class UserBook(Base):
    __tablename__ = "user_book"

    user_book_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), ForeignKey("users.user_id"), nullable=False)
    isbn = Column(String(20), ForeignKey("books.isbn"), nullable=False)

    status = Column(String(10), nullable=False)  # 읽음 / 읽는 중 / 읽을 예정
    start_date = Column(Date)
    end_date = Column(Date)
    rating = Column(Integer)  # 1~5점
    review = Column(Text)
    progress = Column(Integer)  # 읽은 페이지 수
    
    is_public = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    expectation = Column(Text, nullable=True) 
    book = relationship("Book", back_populates="user_books")
    notes = relationship("Note", back_populates="user_book",order_by="desc(Note.created_at)", cascade="all, delete-orphan")