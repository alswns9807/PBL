from sqlalchemy import Column, String, DateTime
from datetime import datetime
from app.database import Base

class User(Base):
    __tablename__ = "users"

    user_id = Column(String(100), primary_key=True, index=True)
    user_name = Column(String(20), nullable=False)
    email = Column(String(50), unique=True, nullable=False)
    profile_picture = Column(String(250), nullable=True)
    bio = Column(String, nullable=True)
    create_at = Column(DateTime, default=datetime.utcnow)
    update_at = Column(DateTime, default=datetime.utcnow)
