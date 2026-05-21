"""maps_service.py — Google Maps + Places API wrapper

This module wraps Google Maps / Places / Directions functionality.
It is safe to import in `mock` mode; network calls will only be made
when `config.settings.GOOGLE_MAPS_API_KEY` is set and `APP_MODE` is
configured for `live` usage.
"""
from typing import List, Dict, Optional
from datetime import datetime
from math import radians, cos, sin, asin, sqrt

from config import settings

try:
    import googlemaps
except Exception:
    googlemaps = None


def _haversine_km(lat1, lon1, lat2, lon2):
    # calculate the great circle distance between two points
    # on the earth (specified in decimal degrees)
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    km = 6371 * c
    return km


def _client():
    if googlemaps is None:
        raise RuntimeError("googlemaps library not available; install googlemaps package")
    key = settings.GOOGLE_MAPS_API_KEY
    if not key:
        raise RuntimeError("GOOGLE_MAPS_API_KEY not configured in settings or .env")
    return googlemaps.Client(key=key)


def geocode_address(address: str) -> Optional[Dict]:
    client = _client()
    res = client.geocode(address)
    if not res:
        return None
    return res[0]


def find_nearby_hospitals_by_address(address: str, radius: int = 5000) -> List[Dict]:
    """Find hospital places near the given address.

    Returns a list of dicts in the same approximate shape as the mock data,
    including `hospital_id`, `hospital_name`, `distance_km`, `rating`, and
    a simple `congestion_level` estimate (mocked).
    """
    client = _client()
    geo = geocode_address(address)
    if not geo:
        return []
    loc = geo["geometry"]["location"]
    lat, lng = loc["lat"], loc["lng"]

    places = client.places_nearby(location=(lat, lng), radius=radius, type="hospital")
    results = []
    for p in places.get("results", []):
        p_loc = p.get("geometry", {}).get("location", {})
        dist = _haversine_km(lat, lng, p_loc.get("lat", lat), p_loc.get("lng", lng))
        results.append({
            "hospital_id": p.get("place_id"),
            "hospital_name": p.get("name"),
            "distance_km": round(dist, 1),
            "rating": p.get("rating", 0.0),
            "vicinity": p.get("vicinity", ""),
            "congestion_level": "UNKNOWN",
            "wait_time_mins": 15,
            "emergency_ready": True,
            "lat": p_loc.get("lat"),
            "lng": p_loc.get("lng"),
        })
    return results


def get_directions_eta(origin: str, destination_lat: float, destination_lng: float) -> Optional[int]:
    """Return estimated travel time in minutes using Directions API."""
    client = _client()
    dest = f"{destination_lat},{destination_lng}"
    routes = client.directions(origin, dest, mode="driving", departure_time=datetime.now())
    if not routes:
        return None
    legs = routes[0].get("legs", [])
    if not legs:
        return None
    duration = legs[0].get("duration", {}).get("value")  # seconds
    if duration is None:
        return None
    return int(duration / 60)

