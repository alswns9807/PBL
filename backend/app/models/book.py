from sqlalchemy import Column, Integer, String, Date, Text, ForeignKey
from app.database import Base

class Book(Base):
    __tablename__ = "books"

    isbn = Column(String(20), primary_key=True, index=True) #isbn을 키로 설정
    title = Column(String(100), nullable=False)
    author = Column(String(50), nullable=False)
    publisher = Column(String(50))
    published_date = Column(Date)
    cover_image = Column(String(255))
    description = Column(Text)
    genre = Column(String(50))
    page_count = Column(Integer)
