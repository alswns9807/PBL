# import os
# import openai
# import json
# from dotenv import load_dotenv
# from sqlalchemy.orm import Session
# from app.models.book import Book
# from app.models.reading_records import UserBook
# from app.schemas.recommendation import RecommendedBook

# # .env 로드
# load_dotenv()
# openai.api_key = os.getenv("OPENAI_API_KEY")

# #사용자의 읽은 책 리뷰 + 읽을 예정 기대평을 정리해서 반환
# def collect_user_texts(db: Session, user_id: int) -> str:
#     user_books = db.query(UserBook).filter(
#         UserBook.user_id == user_id
#     ).all()

#     read_reviews = []
#     expected_reviews = []

#     for ub in user_books:
#         if ub.status == "읽음" and ub.review:
#             read_reviews.append(f"- {ub.book.title}: {ub.review}")
#         elif ub.status == "읽을 예정" and ub.expectation:
#             expected_reviews.append(f"- {ub.book.title}: {ub.expectation}")

#     prompt_text = "읽은 책 리뷰:\n" + "\n".join(read_reviews) + "\n\n읽을 예정 기대평:\n" + "\n".join(expected_reviews)
#     return prompt_text

# def collect_candidate_books(db: Session, user_id: int, limit: int = 30):
#     """추천 후보 책 30권 조회"""
#     read_isbns = db.query(UserBook.isbn).filter(UserBook.user_id == user_id).subquery()

#     candidates = db.query(Book).filter(
#         Book.description.isnot(None),
#         ~Book.isbn.in_(read_isbns)
#     ).limit(limit).all()

#     return candidates

# def create_prompt(user_text: str, candidate_books: list) -> str:
#     """GPT에 보낼 프롬프트 생성"""
#     candidate_list = "\n".join(
#         [f"{idx+1}. {book.title}: {book.description}" for idx, book in enumerate(candidate_books)]
#     )
#     prompt = f"""
# [사용자 취향 정보]
# {user_text}

# [추천 후보 책 리스트]
# {candidate_list}

# [요청]
# 위 사용자 취향과 추천 후보 책 목록을 참고하여,
# 사용자가 가장 좋아할 것 같은 책 10권을 골라주세요.
# 각 추천 책에는 간단한 이유도 추가해주세요.
# 결과는 JSON 형식으로 출력해주세요:

# [
#   {{"isbn": "ISBN", "이유": "추천 이유"}}
# ]
# """
#     return prompt

# def parse_recommendations(content: str, db: Session) -> list[RecommendedBook]:
#     """GPT 응답을 파싱해서 추천 결과 리스트 반환"""
#     try:
#         data = json.loads(content)
#     except json.JSONDecodeError:
#         return []

#     recommended_books = []
#     for item in data:
#         isbn = item.get("isbn")
#         if not isbn:
#             continue

#         book = db.query(Book).filter(Book.isbn == isbn).first()
#         if book:
#             registered_count = len(book.user_books) if book.user_books else 0

#             recommended_books.append(
#                 RecommendedBook(
#                     isbn=book.isbn,
#                     title=book.title,
#                     author=book.author,
#                     publisher=book.publisher,
#                     cover_image=book.cover_image,
#                     registered_count=registered_count
#                 )
#             )
#     return recommended_books

# def get_gpt_recommendations(db: Session, user_id: int, top_k: int = 10):
#     """GPT 호출해서 책 추천"""
#     user_text = collect_user_texts(db, user_id)
#     candidate_books = collect_candidate_books(db, user_id, limit=30)

#     if not user_text.strip() or not candidate_books:
#         return []

#     prompt = create_prompt(user_text, candidate_books)

#     response = openai.ChatCompletion.create(
#         model="gpt-4o",  # (추후 모델 변경 가능)
#         messages=[
#             {"role": "system", "content": "당신은 훌륭한 북 큐레이터입니다."},
#             {"role": "user", "content": prompt}
#         ],
#         temperature=0.7,
#         max_tokens=2000,
#         n=1
#     )

#     content = response['choices'][0]['message']['content']

#     return parse_recommendations(content, db)
