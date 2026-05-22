# language_detector.py — Urdu / Roman Urdu / English classifier
# Step 3: Full logic implemented here

URDU_KEYWORDS = [
    "meri", "mujhe", "hai", "nahi", "dard", "bukhar", "saans", "hosh", "dil", "chest",
    "khun", "zakhm", "tabiyat", "aliya", "dawai"
]


def detect_language(text: str) -> str:
    text_lower = text.lower()
    if any(keyword in text_lower for keyword in URDU_KEYWORDS):
        return "Urdu/Roman Urdu"
    return "English"
