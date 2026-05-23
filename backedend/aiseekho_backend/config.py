# config.py — App configuration loader

# pyrefly: ignore [missing-import]
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_MODE: str = "mock"          # "mock" or "live"
    APP_NAME: str = "AI  Healthcare Orchestration Platform"
    DEFAULT_CITY: str = "Karachi"

    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "models/gemini-2.5-pro"
    # Backwards compatible single key (kept for legacy .env)
    GOOGLE_MAPS_API_KEY: str = ""
    # Preferred for Android client usage (package+SHA1 restricted)
    GOOGLE_MAPS_ANDROID_KEY: str = ""
    # Preferred for server-side calls (restrict by IP or leave appropriately)
    GOOGLE_MAPS_SERVER_KEY: str = ""
    FIREBASE_PROJECT_ID: str = ""
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""

    class Config:
        env_file = ".env"
settings = Settings()
