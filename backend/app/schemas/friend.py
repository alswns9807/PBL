from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum
from datetime import datetime

class FriendStatus(str, Enum):
    pending = "pending"
    accepted = "accepted"

# 친구 요청 생성용
class FriendRequestCreate(BaseModel):
    requester_id: int = Field(..., description="친구 요청할 ID")
    receiver_id: int = Field(..., description="친구 요청을 받을 유저의 ID")

# 친구 상태 업데이트용 (수락 등)
class FriendStatusUpdate(BaseModel):
    friend_id: int = Field(..., description="친구 요청 ID")
    current_user_id: int = Field(..., description="현재 사용자 ID (수신자)")
    status: FriendStatus = Field(..., description="수정할 상태 (예: accepted)")

# 친구 관계 단건 조회용
class FriendResponse(BaseModel):
    id: int
    requester_id: int
    receiver_id: int
    status: FriendStatus
    requested_at: datetime
    accepted_at: Optional[datetime] = None

    class Config:
        orm_mode = True

# 친구 목록용 (상대 유저 정보 포함)
class FriendUserInfo(BaseModel):
    user_id: int
    name: str
    email: str
    
    class Config:
        orm_mode = True

class FriendWithUser(BaseModel):
    friend_id: int
    friend: FriendUserInfo
    status: FriendStatus
    requested_at: datetime
    accepted_at: Optional[datetime] = None

    class Config:
        orm_mode = True
        
    
class RecommendedBook(BaseModel):
    isbn: str
    title: str
    cover_image: Optional[str]
    rating: int
    review: str
    note: Optional[str] = None
    
    class Config:
        orm_mode = True

class FriendRecommendationResponse(BaseModel):
    friend_id: int
    friend_name: str
    recommended_books: List[RecommendedBook]