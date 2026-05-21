from fastapi import APIRouter, HTTPException
from services.mock_store import filter_traces, get_last_trace, get_trace_by_id
from typing import List, Dict, Optional

router = APIRouter(prefix="/traces", tags=["Traces"])


@router.get("/", response_model=List[Dict])
def get_traces(
    urgency: Optional[str] = None,
    hospital_id: Optional[str] = None,
    since: Optional[str] = None,
    until: Optional[str] = None,
):
    return filter_traces(urgency=urgency, hospital_id=hospital_id, since=since, until=until)


@router.get("/last")
def get_last():
    trace = get_last_trace()
    if trace is None:
        raise HTTPException(status_code=404, detail="No traces available")
    return trace


@router.get("/{trace_id}")
def get_trace(trace_id: str):
    trace = get_trace_by_id(trace_id)
    if trace is None:
        raise HTTPException(status_code=404, detail="Trace not found")
    return trace
