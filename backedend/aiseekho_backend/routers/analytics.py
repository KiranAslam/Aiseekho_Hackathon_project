# GET /hospital-analytics — Step 4 implementation

from fastapi import APIRouter
from models.response_models import AnalyticsResponse
from services.mock_data import get_hospital_analytics, load_city_hospitals
from services.mock_store import list_bookings
from typing import List, Dict
from collections import Counter
from datetime import datetime

router = APIRouter(prefix="/hospital-analytics", tags=["Analytics"])


@router.get("/", response_model=List[AnalyticsResponse])
def hospital_analytics(city: str = "Karachi"):
    return get_hospital_analytics(city)


@router.get("/insights", response_model=List[AnalyticsResponse])
def hospital_insights(city: str = "Karachi"):
    hospitals = load_city_hospitals(city)
    bookings = list_bookings()

    results: List[Dict] = []
    for h in hospitals:
        name = h.get("hospital_name")
        hb = [b for b in bookings if b.get("provider_name") == name]

        if hb:
            days = []
            hours = []
            for b in hb:
                ts = b.get("created_at")
                if ts:
                    try:
                        dt = datetime.fromisoformat(ts.replace("Z", ""))
                        days.append(dt.strftime("%A"))
                        hours.append(dt.hour)
                    except Exception:
                        pass

            most_common_day = Counter(days).most_common(1)[0][0] if days else "Unknown"
            peak_hour = f"{min(hours)}:00 - {max(hours)}:00" if hours else h.get("peak_hours", "N/A")
            service_load = "HIGH" if len(hb) >= 3 else "MEDIUM" if len(hb) == 2 else "LOW"
        else:
            most_common_day = h.get("peak_day", "Unknown")
            peak_hour = h.get("peak_hours", "N/A")
            service_load = h.get("emergency_load", "LOW")

        results.append({
            "hospital_name": name,
            "peak_day": most_common_day,
            "peak_hours": peak_hour,
            "most_busy_ward": h.get("specialties", ["General"])[0],
            "emergency_load": service_load,
        })

    return results
