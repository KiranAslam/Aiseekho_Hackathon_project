# POST /analyze-request — Step 4 implementation

from fastapi import APIRouter
from models.request_models import AnalyzeRequest
from models.response_models import AnalyzeResponse
from services.mock_engine import run_pipeline

router = APIRouter(prefix="/analyze-request", tags=["Analysis"])

@router.post("/", response_model=AnalyzeResponse)
def analyze_request(body: AnalyzeRequest):
    return run_pipeline(body.message, body.location, body.preferred_time)
