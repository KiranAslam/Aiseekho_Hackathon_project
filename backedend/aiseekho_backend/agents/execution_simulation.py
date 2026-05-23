import random
from datetime import datetime, timedelta, timezone
from services import mock_store


def _normalize_time(requested_time: str) -> str:
    requested_time = requested_time or "As soon as possible"
    text = requested_time.lower()
    if "tomorrow" in text or "kal" in text:
        return "Tomorrow 10:00 AM"
    if "morning" in text or "subah" in text:
        return "Today 10:00 AM"
    if "evening" in text or "shaam" in text:
        return "Today 6:00 PM"
    return requested_time


def run(hospital: dict, urgency: str, requested_time: str, symptom: str) -> dict:
    booking_id = f"EMG{random.randint(100, 999)}"
    token = f"TKN{random.randint(1000, 9999)}"
    scheduled_time = _normalize_time(requested_time)
    provider_name = hospital.get("hospital_name", hospital.get("provider_name", "Unknown Provider"))
    eta = hospital.get("eta", "N/A")

    confirmation_message = (
        f"Emergency booking confirmed at {provider_name} for {symptom} symptoms. "
        f"Scheduled time: {scheduled_time}. Estimated arrival: {eta}."
    )

    booking_record = {
        "provider_id": hospital.get("hospital_id", hospital.get("provider_id", "N/A")),
        "provider_name": provider_name,
        "booking_status": "Confirmed",
        "booking_id": booking_id,
        "appointment_time": scheduled_time,
        "token": token,
        "requested_time": requested_time,
        "urgency": urgency,
        "message": confirmation_message,
        "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }

    # persist in mock store for later retrieval
    try:
        mock_store.add_booking(booking_record)
    except Exception:
        # best-effort persistence; ignore store failures in mock mode
        pass

    return booking_record
