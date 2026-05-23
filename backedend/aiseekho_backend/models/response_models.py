# Pydantic response schemas

from pydantic import BaseModel
from typing import List, Optional

class AnalyzeResponse(BaseModel):
    urgency: str
    symptom: str
    request_type: str
    requested_time: Optional[str] = None
    selected_hospital: str
    location: Optional[str] = None
    hospital_id: str
    distance: str
    eta: str
    wait_time: str
    hospital_rating: float
    booking_id: str
    reasoning_logs: List[str]
    trace_id: Optional[str] = None
    emergency_note: Optional[str] = None
    ops_insights: Optional[List[str]] = None
    follow_up: Optional[str] = None
    hospital_lat: Optional[float] = None
    hospital_lng: Optional[float] = None
    origin_lat: Optional[float] = None
    origin_lng: Optional[float] = None
    route_polyline: Optional[str] = None
    congestion_level: Optional[str] = None
    traffic_condition: Optional[str] = None
    vicinity: Optional[str] = None
    # Optional detailed candidate list / ranked hospitals
    ranked_hospitals: Optional[List[dict]] = None

class BookingResponse(BaseModel):
    booking_status: str
    booking_id: str
    appointment_time: str
    token: Optional[str] = None
    hospital_name: Optional[str] = None

class AnalyticsResponse(BaseModel):
    hospital_name: str
    peak_day: str
    peak_hours: str
    most_busy_ward: str
    emergency_load: str
