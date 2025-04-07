## 초기 DB 세팅
0. CREATE DATABASE bookmate;
1. PostgreSQL에서 `init_schema.sql` 실행
2. FastAPI 실행


##초기 터미널 실행
1. python -m venv venv
2. source venv/bin/activate  # Windows면 venv\Scripts\activate
3. pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv pydanti
4. pip install pydantic[email]
5. pip install httpx
6. uvicorn app.main:app --reload



## 주소
http://localhost:8000/docs 접속

#
pip install -r requirements.txt