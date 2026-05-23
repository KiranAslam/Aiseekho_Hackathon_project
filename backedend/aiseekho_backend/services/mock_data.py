import json
import os
from typing import List, Dict, Optional

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

DEFAULT_HOSPITALS = [
    {
        "hospital_id": "KHI001",
        "hospital_name": "City Care Hospital",
        "city": "Karachi",
        "specialties": ["Cardiology", "Emergency"],
        "rating": 4.8,
        "distance_km": 2.1,
        "wait_time_mins": 20,
        "congestion_level": "HIGH",
        "emergency_ready": True,
        "traffic_delay_mins": 12,
        "patient_capacity": "High",
        "hospital_lat": 24.8515,
        "hospital_lng": 67.0099,
    },
    {
        "hospital_id": "KHI002",
        "hospital_name": "Sindh General Hospital",
        "city": "Karachi",
        "specialties": ["General", "Trauma"],
        "rating": 4.5,
        "distance_km": 3.8,
        "wait_time_mins": 25,
        "congestion_level": "MEDIUM",
        "emergency_ready": True,
        "traffic_delay_mins": 15,
        "patient_capacity": "Medium",
        "hospital_lat": 24.8437,
        "hospital_lng": 67.0265,
    },
    {
        "hospital_id": "KHI003",
        "hospital_name": "Clifton Medical Center",
        "city": "Karachi",
        "specialties": ["Internal Medicine", "Emergency"],
        "rating": 4.7,
        "distance_km": 5.4,
        "wait_time_mins": 15,
        "congestion_level": "LOW",
        "emergency_ready": True,
        "traffic_delay_mins": 10,
        "patient_capacity": "Medium",
        "hospital_lat": 24.7726,
        "hospital_lng": 67.0181,
    },
    {
        "hospital_id": "KHI004",
        "hospital_name": "Sea View Clinic",
        "city": "Karachi",
        "specialties": ["Primary Care", "Outpatient"],
        "rating": 4.2,
        "distance_km": 6.9,
        "wait_time_mins": 10,
        "congestion_level": "LOW",
        "emergency_ready": False,
        "hospital_lat": 24.7500,
        "hospital_lng": 67.0200,
        "traffic_delay_mins": 8,
        "patient_capacity": "Low",
    },
]

DEFAULT_ANALYTICS = [
    {
        "hospital_name": "City Care Hospital",
        "peak_day": "Monday",
        "peak_hours": "6 PM - 10 PM",
        "most_busy_ward": "Emergency",
        "emergency_load": "HIGH",
    },
    {
        "hospital_name": "Sindh General Hospital",
        "peak_day": "Wednesday",
        "peak_hours": "4 PM - 8 PM",
        "most_busy_ward": "Trauma",
        "emergency_load": "MEDIUM",
    },
    {
        "hospital_name": "Clifton Medical Center",
        "peak_day": "Friday",
        "peak_hours": "2 PM - 6 PM",
        "most_busy_ward": "Internal Medicine",
        "emergency_load": "LOW",
    },
]

CITY_CENTER_LOOKUP = {
    "karachi": (24.8607, 67.0011),
    "lahore": (31.5204, 74.3587),
    "islamabad": (33.6844, 73.0479),
    "rawalpindi": (33.5651, 73.0169),
    "faisalabad": (31.4504, 73.1350),
    "multan": (30.1575, 71.5249),
    "peshawar": (34.0151, 71.5249),
    "quetta": (30.1798, 66.9750),
    "hyderabad": (25.3960, 68.3578),
    "sialkot": (32.4945, 74.5229),
    "gujranwala": (32.1877, 74.1945),
}


def _normalize_city(city: str) -> str:
    return (city or "").strip().lower()


def _list_city_files() -> List[str]:
    if not os.path.isdir(DATA_DIR):
        return []
    return sorted(
        os.path.join(DATA_DIR, name)
        for name in os.listdir(DATA_DIR)
        if name.startswith("hospitals_") and name.endswith(".json")
    )


def _city_center(city: str) -> tuple[float, float]:
    city_key = _normalize_city(city)
    return CITY_CENTER_LOOKUP.get(city_key, CITY_CENTER_LOOKUP["karachi"])


def _generate_city_hospitals(city: str) -> List[Dict]:
    lat, lng = _city_center(city)
    city_name = city.strip() or "Requested city"
    templates = [
        ("Central Emergency Hospital", ["Emergency", "Cardiology"], 4.8, 2.0, 16, "HIGH", True, 10, "High"),
        ("City General Hospital", ["General", "Internal Medicine"], 4.5, 3.6, 22, "MEDIUM", True, 12, "High"),
        ("Specialty Care Center", ["Pediatrics", "Diagnostics"], 4.4, 4.8, 18, "MEDIUM", True, 11, "Medium"),
        ("Neighborhood Health Clinic", ["Primary Care", "Outpatient"], 4.2, 6.1, 12, "LOW", False, 8, "Low"),
        ("24/7 Urgent Care Unit", ["Emergency", "Trauma"], 4.6, 5.3, 14, "HIGH", True, 9, "Medium"),
    ]
    hospitals: List[Dict] = []
    for idx, (name, specialties, rating, distance, wait, congestion, emergency_ready, delay, capacity) in enumerate(templates, start=1):
        hospitals.append({
            "hospital_id": f"{_normalize_city(city)[:3].upper() or 'CITY'}{idx:03d}",
            "hospital_name": f"{city_name} {name}",
            "city": city_name,
            "specialties": specialties,
            "rating": rating,
            "distance_km": round(distance, 1),
            "wait_time_mins": wait,
            "congestion_level": congestion,
            "emergency_ready": emergency_ready,
            "traffic_delay_mins": delay,
            "patient_capacity": capacity,
            "hospital_lat": round(lat + (idx * 0.01), 6),
            "hospital_lng": round(lng + (idx * 0.01), 6),
        })
    return hospitals


def _collect_catalog_hospitals() -> List[Dict]:
    hospitals: List[Dict] = []
    for file_path in _list_city_files():
        data = _load_json_file(file_path)
        if data:
            hospitals.extend(data)
    return hospitals


def _load_json_file(path: str) -> Optional[List[Dict]]:
    if not os.path.exists(path):
        return None

    try:
        with open(path, "r", encoding="utf-8") as handle:
            data = json.load(handle)
            if isinstance(data, list) and data:
                return data
    except Exception:
        return None

    return None


def load_city_hospitals(city: str) -> List[Dict]:
    city_key = _normalize_city(city)
    path = os.path.join(DATA_DIR, f"hospitals_{city_key}.json")
    hospitals = _load_json_file(path)
    if hospitals:
        return hospitals
    # Prefer a matching file, then a richer cross-city catalog, then a generated city-specific fallback.
    catalog = _collect_catalog_hospitals()
    if catalog:
        matched = [
            h for h in catalog
            if _normalize_city(str(h.get("city", ""))) == city_key
        ]
        if matched:
            return matched

        # If the city is known in the catalog but not backed by a dedicated file, return the full catalog.
        if city_key in {
            _normalize_city(str(h.get("city", "")))
            for h in catalog
            if h.get("city")
        }:
            return catalog

    if city_key in {"karachi", "lahore", "islamabad", "rawalpindi", "faisalabad", "multan", "peshawar", "quetta", "hyderabad", "sialkot", "gujranwala"}:
        return _generate_city_hospitals(city)

    return _generate_city_hospitals(city)


def get_hospital_by_id(hospital_id: str) -> Optional[Dict]:
    all_hospitals = DEFAULT_HOSPITALS + _collect_catalog_hospitals()
    for hospital in all_hospitals:
        if hospital.get("hospital_id") == hospital_id:
            return hospital
    return None


def get_hospital_analytics(city: str) -> List[Dict]:
    city_key = _normalize_city(city)
    hospitals = load_city_hospitals(city)
    if not hospitals:
        return DEFAULT_ANALYTICS

    analytics: List[Dict] = []
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    for index, hospital in enumerate(hospitals):
        specialties = hospital.get("specialties") or ["General"]
        peak_day = days[index % len(days)]
        wait = int(hospital.get("wait_time_mins", 15))
        peak_start = max(8, min(20, wait // 2 + 8))
        peak_end = min(23, peak_start + 4)
        analytics.append({
            "hospital_name": hospital.get("hospital_name", f"{city.title()} Hospital"),
            "peak_day": peak_day,
            "peak_hours": f"{peak_start} PM - {peak_end} PM",
            "most_busy_ward": specialties[0],
            "emergency_load": hospital.get("congestion_level", "LOW"),
        })

    return analytics
