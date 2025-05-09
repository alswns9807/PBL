from transformers import AutoTokenizer, AutoModel
import torch
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.orm import Session
from app.models.book import Book
from app.models.reading_records import UserBook

# 모델 초기화 (최초 1회만)
tokenizer = AutoTokenizer.from_pretrained("jhgan/ko-sroberta-multitask")
model = AutoModel.from_pretrained("jhgan/ko-sroberta-multitask")

def compute_embedding(text: str) -> np.ndarray:
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512)
    with torch.no_grad():
        outputs = model(**inputs)
    embedding = outputs.last_hidden_state.mean(dim=1).squeeze().numpy()
    return embedding

def get_ai_recommendations(db: Session, user_id: int, top_k: int = 10):
    # 1. 사용자의 UserBook 중 읽음 + 리뷰/한줄평 있는 것 가져오기
    user_books = db.query(UserBook).filter(
        UserBook.user_id == user_id,
        UserBook.status == "읽음",
        (UserBook.review != None) | (UserBook.expectation != None)
    ).all()

    if not user_books:
        return []

    # 2. 사용자의 텍스트 합치기
    user_text = " ".join(
        [ub.review or ub.expectation for ub in user_books if ub.review or ub.expectation]
    )

    if not user_text.strip():
        return []

    user_embedding = compute_embedding(user_text)

    # 3. 추천 대상 책 목록 불러오기 (책 설명이 있는 책만)
    books = db.query(Book).filter(Book.description != None).all()

    # 4. 사용자가 이미 읽은 ISBN은 제외
    read_isbns = {ub.isbn for ub in user_books}
    candidate_books = [book for book in books if book.isbn not in read_isbns]

    if not candidate_books:
        return []

    # 5. 책 설명 임베딩
    book_embeddings = []
    for book in candidate_books:
        book_embedding = compute_embedding(book.description)
        book_embeddings.append(book_embedding)

    # 6. 코사인 유사도 계산
    similarities = cosine_similarity(
        [user_embedding],
        book_embeddings
    )[0]

    # 7. 유사도 + 등록자 수 고려해서 정렬
    scored_books = []
    for idx, book in enumerate(candidate_books):
        score = similarities[idx]
        registered_count = len(book.user_books) if book.user_books else 0
        scored_books.append((book, score, registered_count))

    # 유사도 우선, 등록자 수 다음으로 정렬
    scored_books.sort(key=lambda x: (-x[1], -x[2]))

    # 8. top_k 추출 + 추천 이유 추가
    recommended = []
    for book, _, registered_count in scored_books[:top_k]:
        recommended.append({
            "isbn": book.isbn,
            "title": book.title,
            "author": book.author,
            "publisher": book.publisher,
            "cover_image": book.cover_image,
            "registered_count": registered_count,
            "reason": "당신의 리뷰/기대평과 유사한 책"
        })

    return recommended
