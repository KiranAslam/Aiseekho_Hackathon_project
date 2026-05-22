# time_utils.py — Peak hour detection helpers

from datetime import datetime

PEAK_HOURS = {
    "morning": (8, 11),
    "evening": (18, 22),
}

def is_peak_hour() -> bool:
    hour = datetime.now().hour
    for _, (start, end) in PEAK_HOURS.items():
        if start <= hour <= end:
            return True
    return False

def current_time_label() -> str:
    hour = datetime.now().hour
    if 6 <= hour < 12:
        return "morning"
    elif 12 <= hour < 17:
        return "afternoon"
    elif 17 <= hour < 22:
        return "evening"
    return "night"
