## 초기 DB 세팅
0. CREATE DATABASE bookmate;
1. PostgreSQL에서 `init_schema.sql` 실행
2. FastAPI 실행


##초기 터미널 실행
1. python -m venv venv
2. source venv/bin/activate  # Windows면 venv\Scripts\activate

##필요 설치파일
pip install -r requirements.txt

##이후 실행
uvicorn app.main:app --reload



## 주소
http://localhost:8000/docs 접속

