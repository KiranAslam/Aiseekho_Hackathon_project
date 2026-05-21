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
    city_key = city.strip().lower()
    path = os.path.join(DATA_DIR, f"hospitals_{city_key}.json")
    hospitals = _load_json_file(path)
    if hospitals:
        return hospitals
    if city_key == "lahore":
        return [
            {
                "hospital_id": "LHE001",
                "hospital_name": "Lahore Emergency Hospital",
                "city": "Lahore",
                "specialties": ["Emergency", "Cardiology"],
                "rating": 4.7,
                "distance_km": 2.7,
                "wait_time_mins": 18,
                "congestion_level": "HIGH",
                "emergency_ready": True,
                "traffic_delay_mins": 14,
                "patient_capacity": "High",
                "hospital_lat": 31.5497,
                "hospital_lng": 74.3436,
            },
            {
                "hospital_id": "LHE002",
                "hospital_name": "Nishtar Medical Center",
                "city": "Lahore",
                "specialties": ["General", "Pediatrics"],
                "rating": 4.4,
                "distance_km": 4.1,
                "wait_time_mins": 22,
                "congestion_level": "MEDIUM",
                "emergency_ready": True,
                "traffic_delay_mins": 12,
                "patient_capacity": "Medium",
                "hospital_lat": 31.5497,
                "hospital_lng": 74.2633,
            },
            {
                "hospital_id": "LHE003",
                "hospital_name": "Gulberg Care Hospital",
                "city": "Lahore",
                "specialties": ["Outpatient", "Diagnostics"],
                "rating": 4.3,
                "distance_km": 5.9,
                "wait_time_mins": 16,
                "congestion_level": "LOW",
                "emergency_ready": False,
                "traffic_delay_mins": 9,
                "patient_capacity": "Low",
                "hospital_lat": 31.5308,
                "hospital_lng": 74.2164,
            },
        ]
    return DEFAULT_HOSPITALS


def get_hospital_by_id(hospital_id: str) -> Optional[Dict]:
    all_hospitals = DEFAULT_HOSPITALS + load_city_hospitals("Lahore")
    for hospital in all_hospitals:
        if hospital.get("hospital_id") == hospital_id:
            return hospital
    return None


def get_hospital_analytics(city: str) -> List[Dict]:
    city_key = city.strip().lower()
    if city_key == "lahore":
        return [
            {
                "hospital_name": "Lahore Emergency Hospital",
                "peak_day": "Tuesday",
                "peak_hours": "5 PM - 9 PM",
                "most_busy_ward": "Emergency",
                "emergency_load": "HIGH",
            },
            {
                "hospital_name": "Nishtar Medical Center",
                "peak_day": "Thursday",
                "peak_hours": "3 PM - 7 PM",
                "most_busy_ward": "Trauma",
                "emergency_load": "MEDIUM",
            },
        ]
    return DEFAULT_ANALYTICS
