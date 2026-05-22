# urgency_classifier.py — Keyword-based urgency scoring for healthcare messages

HIGH_KEYWORDS = [
    "chest pain", "heart attack", "seene mein dard", "bleeding", "unconscious", "hosh nahi",
    "accident", "stroke", "seizure", "shortness of breath", "breathing problem", "saans",
    "severe pain", "high fever", "burn", "fracture", "emergency", "immediately", "abhi"
]

MEDIUM_KEYWORDS = [
    "fever", "bukhar", "pain", "dard", "nausea", "vomiting", "vomit", "earache", "cough",
    "soon", "tomorrow", "next day", "aaj", "subah", "later", "need", "required"
]

LOW_KEYWORDS = [
    "checkup", "routine", "appointment", "consultation", "general", "thoda", "thoda sa"
]


def classify_urgency(text: str) -> str:
    text_lower = text.lower()
    if any(keyword in text_lower for keyword in HIGH_KEYWORDS):
        return "HIGH"
    if any(keyword in text_lower for keyword in MEDIUM_KEYWORDS):
        return "MEDIUM"
    return "LOW"
