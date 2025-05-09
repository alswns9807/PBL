from sqlalchemy import Column, Integer, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class Follow(Base):
    __tablename__ = "follows"
    __table_args__ = (UniqueConstraint("follower_id", "followed_id", name="unique_follow"),)

    id = Column(Integer, primary_key=True, index=True)
    follower_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    followed_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    followed_at = Column(DateTime, default=datetime.utcnow)

    follower = relationship("User", foreign_keys=[follower_id], backref="following_relations")
    followed = relationship("User", foreign_keys=[followed_id], backref="follower_relations")
