from sqlalchemy import Column, Integer, String, Date, Text, ForeignKey, DateTime
from datetime import datetime
from app.database import Base

class UserBook(Base):
    __tablename__ = "user_book"

    user_book_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    isbn = Column(String(20), ForeignKey("books.isbn"), nullable=False)

    status = Column(String(10), nullable=False)  # 읽음 / 읽는 중 / 읽을 예정
    start_date = Column(Date)
    end_date = Column(Date)
    rating = Column(Integer)  # 1~5점
    review = Column(Text)
    progress = Column(Integer)  # 읽은 페이지 수
    
    created_at = Column(DateTime, default=datetime.utcnow)
    expectation = Column(Text, nullable=True) 