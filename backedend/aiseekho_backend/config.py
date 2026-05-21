# config.py — App configuration loader

# pyrefly: ignore [missing-import]
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_MODE: str = "mock"          # "mock" or "live"
    APP_NAME: str = "AI  Healthcare Orchestration Platform"
    DEFAULT_CITY: str = "Karachi"

    GEMINI_API_KEY: str = ""
    GOOGLE_MAPS_API_KEY: str = ""
    FIREBASE_PROJECT_ID: str = ""
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""

    class Config:
        env_file = ".env"
settings = Settings()
