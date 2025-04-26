from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List

from app.database import get_db
from app.models.reading_records import UserBook
from app.models.user import User
from app.models.note import Note
from app.models.friend import Friend
from app.models.book import Book
from app.schemas.friend import (
    FriendRequestCreate,
    FriendResponse,
    FriendWithUser,
    FriendUserInfo,
    FriendRecommendationResponse,
    RecommendedBook
)

router = APIRouter(
    prefix="/friends",
    tags=["Friends"]
)


# 공통 응답 구조 함수
def build_friend_response(friend: Friend, current_user_id: int) -> FriendWithUser:
    if friend.requester_id == current_user_id:
        counterpart = friend.receiver
    else:
        counterpart = friend.requester

    return FriendWithUser(
        friend_id=friend.id,
        friend=FriendUserInfo(
            user_id=counterpart.user_id,
            name=counterpart.user_name,
            email=counterpart.email
        ),
        status=friend.status,
        requested_at=friend.requested_at,
        accepted_at=friend.accepted_at
    )


#  친구 요청 보내기
@router.post("/", response_model=FriendResponse)
def send_friend_request(request: FriendRequestCreate, db: Session = Depends(get_db)):
    if request.requester_id == request.receiver_id:
        raise HTTPException(status_code=400, detail="자기 자신에게는 친구 요청을 보낼 수 없습니다.")

    existing = db.query(Friend).filter(
        ((Friend.requester_id == request.requester_id) & (Friend.receiver_id == request.receiver_id)) |
        ((Friend.requester_id == request.receiver_id) & (Friend.receiver_id == request.requester_id))
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="이미 친구 요청이 존재하거나 친구입니다.")

    friend_request = Friend(
        requester_id=request.requester_id,
        receiver_id=request.receiver_id,
        status="pending",
        requested_at=datetime.utcnow()
    )
    db.add(friend_request)
    db.commit()
    db.refresh(friend_request)
    return friend_request


# 친구 요청 수락
@router.put("/{friend_id}/accept", response_model=FriendWithUser)
def accept_friend_request(friend_id: int, current_user_id: int = Query(...), db: Session = Depends(get_db)):
    # 요청 조회
    friend_request = db.query(Friend).filter(Friend.id == friend_id).first()
    if not friend_request:
        raise HTTPException(status_code=404, detail="요청이 존재하지 않습니다.")

    # 수신자 확인
    if friend_request.receiver_id != current_user_id:
        raise HTTPException(status_code=403, detail="이 요청을 수락할 권한이 없습니다.")

    # 이미 수락됨
    if friend_request.status == "accepted":
        raise HTTPException(status_code=400, detail="이미 수락된 요청입니다.")

    # 수락 처리
    friend_request.status = "accepted"
    friend_request.accepted_at = datetime.utcnow()
    db.commit()
    db.refresh(friend_request)

    # 상대방 정보 포함 응답
    requester = friend_request.requester
    return FriendWithUser(
        friend_id=friend_request.id,
        friend=FriendUserInfo(
            user_id=requester.user_id,
            name=requester.user_name,
            email=requester.email
        ),
        status=friend_request.status,
        requested_at=friend_request.requested_at,
        accepted_at=friend_request.accepted_at
    )



# 친구 요청 거절 or 삭제
@router.delete("/{friend_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_friend_request(friend_id: int, db: Session = Depends(get_db)):
    request = db.query(Friend).filter(Friend.id == friend_id).first()
    if not request:
        raise HTTPException(status_code=404, detail="친구 요청이 존재하지 않습니다.")

    db.delete(request)
    db.commit()
    return


# 친구 목록 조회 (양방향)
@router.get("/", response_model=List[FriendWithUser])
def get_all_friends(current_user_id: int = Query(...), db: Session = Depends(get_db)):
    friends = db.query(Friend).filter(
        ((Friend.requester_id == current_user_id) | (Friend.receiver_id == current_user_id)) &
        (Friend.status == "accepted")
    ).all()

    return [build_friend_response(f, current_user_id) for f in friends]


# 받은 친구 요청 목록
@router.get("/requests/received", response_model=List[FriendWithUser])
def get_received_requests(current_user_id: int = Query(...), db: Session = Depends(get_db)):
    requests = db.query(Friend).filter(
        Friend.receiver_id == current_user_id,
        Friend.status == "pending"
    ).all()

    return [build_friend_response(f, current_user_id) for f in requests]


# 보낸 친구 요청 목록
@router.get("/requests/sent", response_model=List[FriendWithUser])
def get_sent_requests(current_user_id: int = Query(...), db: Session = Depends(get_db)):
    requests = db.query(Friend).filter(
        Friend.requester_id == current_user_id,
        Friend.status == "pending"
    ).all()

    return [build_friend_response(f, current_user_id) for f in requests]

# 친추 추천 도서 목록
@router.get("/{friend_id}/recommendations", response_model=FriendRecommendationResponse)
def get_recommendations(friend_id: int, db: Session = Depends(get_db)):
    friend = db.query(User).filter(User.user_id == friend_id).first()
    if not friend:
        raise HTTPException(status_code=404, detail="친구 정보 없음")

    records = (
        db.query(UserBook)
        .filter(
            UserBook.user_id == friend_id,
            UserBook.is_public == True,
            UserBook.rating >= 4
        )
        .join(Book)
        .outerjoin(Note, Note.user_book_id == UserBook.user_book_id)
        .order_by(UserBook.rating.desc())
        .limit(10)
        .all()
    )

    recommended_books = []

    for record in records:
        if record.review:
            content = record.review
        elif record.notes:
            content = sorted(record.notes, key=lambda n: n.created_at, reverse=True)[0].content
        else:
            content = ""

        recommended_books.append(
            RecommendedBook(
                isbn=record.book.isbn,
                title=record.book.title,
                cover_image=record.book.cover_image,
                rating=record.rating,
                review=record.review or "",
                note=content
            )
        )

    return FriendRecommendationResponse(
        friend_id=friend.user_id,
        friend_name=friend.user_name,
        recommended_books=[book.model_dump() for book in recommended_books]
    )
    

