# POST /analyze-request — Step 4 implementation

from fastapi import APIRouter
from models.request_models import AnalyzeRequest
from models.response_models import AnalyzeResponse
from services.mock_engine import run_pipeline

router = APIRouter(prefix="/analyze-request", tags=["Analysis"])

@router.post("/", response_model=AnalyzeResponse)
def analyze_request(body: AnalyzeRequest):
    # Debug logging: print incoming message and the pipeline result so logs show what was received
    try:
        print(f"[ANALYZE] Incoming message: {body.message}")
    except Exception:
        pass
    result = run_pipeline(body.message, body.location, body.preferred_time)
    try:
        print(f"[ANALYZE] Pipeline result: {result}")
    except Exception:
        pass
    return result
