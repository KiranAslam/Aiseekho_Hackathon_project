# Pydantic request schemas

from pydantic import BaseModel
from typing import Optional

class AnalyzeRequest(BaseModel):
    message: str
    location: str = "Karachi"
    preferred_time: Optional[str] = None

class BookingRequest(BaseModel):
    hospital_id: str
    urgency: str
    patient_name: str = "Anonymous"
    requested_time: Optional[str] = None
