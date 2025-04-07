from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey
from datetime import datetime
from app.database import Base

class Note(Base):
    __tablename__ = "notes"

    note_id = Column(Integer, primary_key=True, index=True)
    user_book_id = Column(Integer, ForeignKey("user_book.user_book_id"), nullable=False)

    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
