from fastapi import APIRouter
from config import settings
import requests

router = APIRouter(prefix="/maps", tags=["Maps"])


@router.get("/check")
def maps_check(address: str = "Karachi"):
    """Simple diagnostics to verify the Google Maps API key and basic response.

    Returns status and result count; useful to debug API_KEY issues like
    REQUEST_DENIED, API_KEY_INVALID, or ZERO_RESULTS.
    """
    # Prefer server key when available; fall back to legacy key
    key = settings.GOOGLE_MAPS_SERVER_KEY or settings.GOOGLE_MAPS_API_KEY
    if not key:
        return {"ok": False, "error": "GOOGLE_MAPS_API_KEY not configured"}

    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {"address": address, "key": key}
    try:
        resp = requests.get(url, params=params, timeout=10)
        data = resp.json()
    except Exception as exc:
        return {"ok": False, "error": f"Request failed: {exc}"}

    status = data.get("status")
    if status == "OK":
        return {"ok": True, "status": status, "results": len(data.get("results", []))}
    return {"ok": False, "status": status, "error": data.get("error_message"), "raw": data}
