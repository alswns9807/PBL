from sqlalchemy import Column, Integer, ForeignKey, Enum, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from enum import Enum as PyEnum
from app.database import Base


class FriendStatus(PyEnum):
    pending = "pending"     # 요청 보낸 상태
    accepted = "accepted"   # 수락된 상태


class Friend(Base):
    __tablename__ = "friends"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    status = Column(Enum(FriendStatus), default=FriendStatus.pending, nullable=False)
    requested_at = Column(DateTime, default=datetime.utcnow)
    accepted_at = Column(DateTime, nullable=True)

    requester = relationship(
        "User",
        foreign_keys=[requester_id],
        backref="sent_friend_requests",
        lazy="joined"
    )
    receiver = relationship(
        "User",
        foreign_keys=[receiver_id],
        backref="received_friend_requests",
        lazy="joined"
    )
