import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:CafeFausse2026!@localhost:5432/Cafe_Fausse_DB')
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
