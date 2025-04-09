import httpx
from datetime import datetime
from app.config import ALADIN_TTB_KEY, ALADIN_API_URL


async def search_books_from_aladin(query: str, max_results: int = 10):
    params = {
        "ttbkey": ALADIN_TTB_KEY,
        "Query": query,
        "QueryType": "Title",
        "SearchTarget": "Book",
        "output": "js",
        "Version": "20131101",
        "MaxResults": max_results,
        "Cover": "Big",
        "OptResult": "ebookList,usedList,reviewList,fullDescription,toc,story,authors"
    }

    async with httpx.AsyncClient(timeout=5.0) as client:
        try:
            response = await client.get(ALADIN_API_URL, params=params)
            response.raise_for_status()
            data = response.json()
            return data.get("item", [])
        except Exception as e:
            print(f"[❌] 알라딘 검색 실패: {e}")
            return []


async def fetch_book_from_aladin(isbn: str):
    lookup_url = "https://www.aladin.co.kr/ttb/api/ItemLookUp.aspx"
    params = {
        "ttbkey": ALADIN_TTB_KEY,
        "ItemId": isbn,
        "ItemIdType": "ISBN13",
        "output": "js",
        "Cover": "Big",
        "Version": "20131101",
        "OptResult": "ebookList,usedList,reviewList,fullDescription,toc,story,authors"
    }

    async with httpx.AsyncClient(timeout=5.0) as client:
        try:
            response = await client.get(lookup_url, params=params)
            response.raise_for_status()
            data = response.json()
            if not data.get("item"):
                print(f"[⚠️] 알라딘에 ISBN {isbn}에 대한 정보 없음")
                return None

            item = data["item"][0]
            sub = item.get("subInfo", {})

            return {
                "isbn": item.get("isbn13"),
                "title": item.get("title"),
                "author": item.get("author"),
                "publisher": item.get("publisher"),
                "published_date": parse_date_safe(item.get("pubDate")),
                "cover_image": item.get("cover"),
                "description": item.get("description"),
                "genres": extract_main_genres(item.get("categoryName", "")),
                "page_count": sub.get("itemPage", 0)
            }
        except Exception as e:
            print(f"[❌] 알라딘 상세조회 실패: {e}")
            return None


def parse_date_safe(date_str):
    try:
        return datetime.strptime(date_str, "%Y-%m-%d").date()
    except:
        return None


KEYWORD_PRIORITY = [
    # 문학 분류
    ("한국소설", "한국문학"),
    ("프랑스", "외국문학"),
    ("러시아", "외국문학"),
    ("영미", "외국문학"),
    ("일본", "외국문학"),
    ("중국", "외국문학"),
    ("문학", "문학"),
    ("고전", "고전문학"),

    # 장르 소설
    ("판타지", "판타지"),
    ("환상", "판타지"),
    ("SF", "SF"),
    ("추리", "미스터리"),
    ("스릴러", "미스터리"),
    ("공포", "미스터리"),

    # 에세이/인문/사회
    ("에세이", "에세이"),
    ("인문학", "인문"),
    ("심리", "심리"),
    ("철학", "철학"),
    ("사회", "사회"),
    ("정치", "정치"),

    # 실용
    ("경제", "경제"),
    ("투자", "경제"),
    ("주식", "경제"),
    ("인간관계", "자기계발"),
    ("자기계발", "자기계발"),
    ("리더십", "자기계발"),
    ("성공", "자기계발"),
    ("설득", "자기계발"),
    ("커뮤니케이션", "자기계발"),
    ("대화", "자기계발"),
    ("습관", "자기계발"),

    # 라이프스타일
    ("요리", "라이프"),
    ("육아", "라이프"),
    ("건강", "라이프"),
    ("여행", "라이프"),
    ("에세이", "라이프"),

    # 예술/문화
    ("예술", "예술"),
    ("디자인", "예술"),
    ("사진", "예술"),

    # 기타
    ("청소년", "청소년"),
    ("청소년소설", "청소년"),
    ("종교", "종교"),
    ("기독교", "종교"),
]


def extract_main_genres(category_name: str, max_genres: int = 3) -> list[str]:
    if not category_name:
        return ["기타"]

    genres = []
    lowered = category_name.lower()

    for keyword, genre in KEYWORD_PRIORITY:
        if keyword.lower() in lowered and genre not in genres:
            genres.append(genre)
            if len(genres) >= max_genres:
                break

    return genres if genres else ["기타"]
