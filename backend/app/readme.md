## 초기 DB 세팅
0. CREATE DATABASE bookmate;
1. PostgreSQL에서 `init_schema.sql` 실행
2. FastAPI 실행


##초기 터미널 실행
1. python -m venv venv
2. source venv/bin/activate  # Windows면 venv\Scripts\activate

##필요 설치파일
cd app
backend/app 에서 실행
pip install -r requirements.txt

##이후 실행
cd ..
backend 에서 실행
uvicorn app.main:app --reload



## 주소
http://localhost:8000/docs 접속

## 초기 책 등록 순서
books에서 /search 창으로 이동후 책 제목 검색
/fetch 창에서 해당 책의 isbn 입력하여 서버 등록


## 책 추천
사용한 텍스트 유사도 방식: 사전학습 언어모델 기반 문장 임베딩 + 코사인 유사도

Ko-SRoBERTa는 한국어 문장을 의미 기반 벡터로 임베딩하기 위해 훈련된 사전학습 언어모델이다. 
입력된 텍스트는 토큰화가 된 후 모델에 입력되며, 
last_hidden_state의 토큰 벡터 평균(mean pooling)을 사용하여 하나의 문장 임베딩을 얻는다.

이 방식을 사용한 이유는 단순 키워드 중심의 텍스트 유사도(TF-IDF 등)로는 문맥적 의미를 반영하기 어렵기 때문에, 
문장의 의미 자체를 반영할 수 있는 임베딩 기반 방식을 사용한 것이다.

코사인 유사도는 두 벡터 사이의 방향 유사도를 측정하여, 크기와 무관하게 의미의 유사성을 파악하는 데 사용된다. 
사전학습된 언어모델이 출력한 임베딩 벡터는 문맥, 어휘 관계, 문장 구조 등 의미 정보를 고차원 공간에 반영하고 있기 때문에,
이 벡터들 사이의 코사인 유사도를 계산하면 문장 간 의미적 유사성을 정량적으로 측정할 수 있다.

임베딩 되는 방식은
1. Ko-SRoBERTa는 토큰화(subword 단위)하고 각 토큰에 고유 ID를 부여함.
2. 토큰 ID → 임베딩 벡터로 변환
3. Transformer 인코더에 입력
4. 출력: 모든 토큰의 문맥 임베딩