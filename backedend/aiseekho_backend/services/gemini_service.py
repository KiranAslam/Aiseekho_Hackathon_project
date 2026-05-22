"""gemini_service.py — Google Gemini (Generative AI) wrapper

This wrapper uses the `google-generativeai` client if available and
configured via `config.settings.GEMINI_API_KEY`.
"""
from typing import Optional

from config import settings

try:
    import google.generativeai as genai
except Exception:
    genai = None


def _ensure_client():
    if genai is None:
        raise RuntimeError("google-generativeai library not available; install google-generativeai")
    if not settings.GEMINI_API_KEY:
        raise RuntimeError("GEMINI_API_KEY not configured in settings or .env")
    genai.configure(api_key=settings.GEMINI_API_KEY)
    return genai


def analyze_with_gemini(prompt: str, model: str = "gemini") -> str:
    """Send a prompt to Gemini and return the text response.

    This is a thin wrapper; production use should handle safety, retries,
    and structured parsing of Gemini responses.
    """
    client = _ensure_client()
    # Use the simple generate_text API if available; exact invocation may vary
    try:
        response = client.generate_text(model=model, prompt=prompt)
        return response.text if hasattr(response, "text") else str(response)
    except Exception as e:
        raise RuntimeError(f"Gemini request failed: {e}")
