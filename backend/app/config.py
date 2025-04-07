import os
from dotenv import load_dotenv

load_dotenv()  # .env 파일을 로드

ALADIN_TTB_KEY = os.getenv("ALADIN_TTB_KEY")
ALADIN_API_URL = os.getenv("ALADIN_API_URL")
