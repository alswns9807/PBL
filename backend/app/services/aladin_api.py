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
                "genre": item.get("categoryName"),
                "page_count": sub.get("itemPage",0)
            }
        except Exception as e:
            print(f"[❌] 알라딘 상세조회 실패: {e}")
            return None


def parse_date_safe(date_str):
    try:
        return datetime.strptime(date_str, "%Y-%m-%d").date()
    except:
        return None
