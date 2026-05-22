cd C:\Users\AQT\Desktop\aiseekho_backend\aiseekho_backend
.\myenv\Scripts\activate
uvicorn main:app --reload --port 8000# AISeekho 2026 — Autonomous Healthcare Coordination Platform

## Setup
```bash
python -m venv myenv
source myenv/bin/activate  
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Live mode
Set `APP_MODE=live` in `.env` and provide `GEMINI_API_KEY` and `GOOGLE_MAPS_API_KEY` before starting the app.

## Swagger Docs
Visit: http://localhost:8000/docs
