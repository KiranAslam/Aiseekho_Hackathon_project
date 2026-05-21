# main.py — FastAPI Entry Point
# Routers will be registered here in Step 4

# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="AI  Healthcare Orchestration Platform",
    description="Autonomous Healthcare Coordination & Operational Intelligence",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

from routers import analyze, booking, analytics, traces
from config import settings

app.include_router(analyze.router)
app.include_router(booking.router)
app.include_router(analytics.router)
app.include_router(traces.router)

@app.get("/")
def root():
    return {"status": "AISeekho Backend Running", "mode": settings.APP_MODE}
