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
INVALID_TEXT_VALUES = {"", "none", "null", "unknown", "n/a", "not specified", "unspecified"}


def _text_value(value, fallback: str) -> str:
    if value is None:
        return fallback
    if isinstance(value, str):
        cleaned = value.strip()
        return fallback if cleaned.lower() in INVALID_TEXT_VALUES else (cleaned or fallback)
    if isinstance(value, (list, tuple)):
        for item in value:
            text = _text_value(item, "")
            if text:
                return text
        return fallback
    if isinstance(value, dict):
        for key in ("value", "text", "name", "label"):
            if key in value:
                return _text_value(value[key], fallback)
        return fallback
    return str(value).strip() or fallback


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
            symptom = _text_value(parsed.get("symptom"), _extract_symptom(message))
            heuristic_urgency = classify_urgency(message)
            parsed_urgency = _text_value(parsed.get("urgency"), heuristic_urgency).upper()
            urgency = heuristic_urgency if heuristic_urgency == "HIGH" else parsed_urgency
            request_type = _text_value(
                parsed.get("request_type"),
                "Emergency" if urgency == "HIGH" else "Urgent" if urgency == "MEDIUM" else "Routine",
            )
            if urgency == "HIGH":
                request_type = "Emergency"
            requested_time = _text_value(
                parsed.get("requested_time"),
                _extract_requested_time(message, preferred_time),
            )
            resolved_location = _text_value(
                parsed.get("location"),
                _extract_location(message, location),
            )
            if resolved_location.strip().lower() in INVALID_TEXT_VALUES:
                resolved_location = _extract_location(message, location)
            return {
                "agent": "IntentUnderstandingAgent",
                "language": _text_value(parsed.get("language"), detect_language(message)),
                "symptom": symptom,
                "urgency": urgency,
                "request_type": request_type,
                "requested_time": requested_time,
                "location": resolved_location,
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
