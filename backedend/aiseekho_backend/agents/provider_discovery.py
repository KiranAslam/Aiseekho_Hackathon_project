from services.mock_data import load_city_hospitals
from config import settings

try:
    from services.maps_service import find_nearby_hospitals_by_address, get_directions_eta
except Exception:
    find_nearby_hospitals_by_address = None
    get_directions_eta = None

EMERGENCY_TERMS = ["chest pain", "heart", "accident", "stroke", "seizure", "bleeding"]


def _estimate_eta(distance_km: float, traffic_delay_mins: int) -> str:
    eta_mins = int(distance_km * 4 + traffic_delay_mins)
    return f"{max(5, eta_mins)} mins"


def _compute_priority_score(hospital: dict, urgency: str) -> int:
    score = hospital.get("wait_time_mins", 0)
    score += int(hospital.get("distance_km", 0) * 2)
    score -= int(hospital.get("rating", 0) * 5)
    congestion = hospital.get("congestion_level", "LOW").upper()
    score += 20 if congestion == "HIGH" else 10 if congestion == "MEDIUM" else 0
    if urgency == "HIGH" and not hospital.get("emergency_ready", False):
        score += 50
    return score


def run(intent_output: dict, city: str) -> dict:
    # In live mode, prefer Google Maps Places results when available
    raw_hospitals = []
    if settings.APP_MODE == "live" and find_nearby_hospitals_by_address and settings.GOOGLE_MAPS_API_KEY:
        try:
            raw_hospitals = find_nearby_hospitals_by_address(intent_output.get("location", city))
        except Exception:
            raw_hospitals = load_city_hospitals(city)
    else:
        raw_hospitals = load_city_hospitals(city)
    urgency = intent_output.get("urgency", "LOW")
    message = intent_output.get("message", "")
    symptom = intent_output.get("symptom", "Medical Issue")

    candidates = []
    for hospital in raw_hospitals:
        if urgency == "HIGH" and not hospital.get("emergency_ready", False):
            continue

        # If maps_service provided lat/lng and distance_km, compute ETA if possible
        eta_text = hospital.get("eta", None)
        if not eta_text and get_directions_eta and settings.APP_MODE == "live":
            try:
                origin = intent_output.get("location", city)
                eta_mins = get_directions_eta(origin, hospital.get("lat"), hospital.get("lng"))
                if eta_mins is not None:
                    eta_text = f"{eta_mins} mins"
            except Exception:
                eta_text = None

        candidate = {
            "hospital_id": hospital.get("hospital_id") or hospital.get("place_id"),
            "hospital_name": hospital.get("hospital_name") or hospital.get("name"),
            "distance": f"{hospital.get('distance_km', hospital.get('distance', 0))} km",
            "wait_time": f"{hospital.get('wait_time_mins', hospital.get('wait_time', 15))} mins",
            "eta": eta_text or _estimate_eta(hospital.get("distance_km", 0), hospital.get("traffic_delay_mins", 10)),
            "hospital_rating": hospital.get("rating", hospital.get("hospital_rating", 0.0)),
            "congestion_level": hospital.get("congestion_level", "UNKNOWN"),
            "emergency_ready": hospital.get("emergency_ready", True),
            "score": _compute_priority_score(hospital, urgency),
            "reason": "Emergency-ready hospital available." if hospital.get("emergency_ready", True) else "Available for non-emergency cases.",
        }

        if urgency != "HIGH" and any(term in message.lower() for term in EMERGENCY_TERMS):
            candidate["reason"] = "Hospital evaluated for serious symptoms."
        elif symptom.lower().startswith("chest"):
            candidate["reason"] = "Hospital selected based on emergency cardiac symptoms."
        else:
            candidate["reason"] = "Hospital evaluated for symptom severity and congestion."

        candidates.append(candidate)

    candidates.sort(key=lambda item: item["score"])

    if not candidates:
        return {
            "agent": "ProviderDiscoveryAgent",
            "candidates": [],
            "reason": "No hospitals found for the selected location and urgency."
        }

    return {
        "agent": "ProviderDiscoveryAgent",
        "candidates": candidates,
        "reason": f"Found {len(candidates)} candidate hospitals for {city}."
    }
