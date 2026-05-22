from typing import Optional
from utils.language_detector import detect_language
from utils.urgency_classifier import classify_urgency
from config import settings
import json

try:
    from services.gemini_service import analyze_with_gemini
except Exception:
    analyze_with_gemini = None

SYMPTOM_KEYWORDS = [
    "chest pain", "heart pain", "fever", "bukhar", "bleeding",
    "shortness of breath", "saans", "headache", "dard", "accident",
    "seizure", "vomiting", "vomit", "stomach ache", "migraine",
    "pregnancy", "cough", "cold", "fatigue", "injury"
]

LOCATION_KEYWORDS = ["g-13", "karachi", "lahore", "clifton", "nazimabad", "gulshan", "dha"]
TIME_PHRASES = ["tomorrow morning", "kal subah", "today", "aaj", "subah", "evening", "tonight", "now"]


def _extract_symptom(text: str) -> str:
    text_lower = text.lower()
    for phrase in SYMPTOM_KEYWORDS:
        if phrase in text_lower:
            return phrase.title()
    return "General Medical Issue"


def _extract_location(text: str, default: str) -> str:
    text_lower = text.lower()
    for phrase in LOCATION_KEYWORDS:
        if phrase in text_lower:
            return phrase.title()
    return default


def _extract_requested_time(text: str, preferred_time: Optional[str]) -> str:
    if preferred_time:
        return preferred_time
    text_lower = text.lower()
    for phrase in TIME_PHRASES:
        if phrase in text_lower:
            return phrase.title()
    return "As soon as possible"


def run(message: str, location: str, preferred_time: Optional[str] = None) -> dict:
    # If in live mode and Gemini wrapper available, try LLM-based parsing
    if settings.APP_MODE == "live" and analyze_with_gemini and settings.GEMINI_API_KEY:
        prompt = (
            "Extract intent details from the following user message and return a JSON object with keys: "
            "language, symptom, urgency, request_type, requested_time, location.\n\n"
            f"User message: {message}\n"
        )
        try:
            resp = analyze_with_gemini(prompt)
            parsed = json.loads(resp)
            return {
                "agent": "IntentUnderstandingAgent",
                "language": parsed.get("language", detect_language(message)),
                "symptom": parsed.get("symptom", _extract_symptom(message)),
                "urgency": parsed.get("urgency", classify_urgency(message)),
                "request_type": parsed.get("request_type", "Emergency" if classify_urgency(message) == "HIGH" else "Urgent"),
                "requested_time": parsed.get("requested_time", _extract_requested_time(message, preferred_time)),
                "location": parsed.get("location", _extract_location(message, location)),
                "message": message,
            }
        except Exception:
            # fall back to heuristic extraction
            pass

    language = detect_language(message)
    urgency = classify_urgency(message)
    symptom = _extract_symptom(message)
    request_type = "Emergency" if urgency == "HIGH" else "Urgent" if urgency == "MEDIUM" else "Routine"
    requested_time = _extract_requested_time(message, preferred_time)
    detected_location = _extract_location(message, location)

    return {
        "agent": "IntentUnderstandingAgent",
        "language": language,
        "symptom": symptom,
        "urgency": urgency,
        "request_type": request_type,
        "requested_time": requested_time,
        "location": detected_location,
        "message": message,
    }
