"""gemini_service.py — Google Gemini (Generative AI) wrapper

This wrapper prefers the modern `google-genai` client for Gemini models
and falls back to `google-generativeai` for legacy compatibility.
"""
import json
import os
import time
from typing import Optional

from config import settings

try:
    from google import genai as modern_genai
except Exception:
    modern_genai = None

try:
    import google.generativeai as genai
except Exception:
    genai = None


def _normalize_model_name(model: str) -> str:
    model = (model or "").strip()
    if model.startswith("models/"):
        return model.split("/", 1)[1]
    return model


def _load_project_from_adc_file() -> Optional[str]:
    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    if not cred_path:
        return None
    try:
        with open(cred_path, "r", encoding="utf-8") as f:
            payload = json.load(f)
        return payload.get("project_id")
    except Exception:
        return None


def _ensure_modern_client():
    if modern_genai is None:
        return None

    # Prefer API key only when it looks like a standard Gemini key.
    # Account-bound/service-account flows may not use an AIza-style key.
    api_key = (settings.GEMINI_API_KEY or "").strip()
    if api_key.startswith("AIza"):
        return modern_genai.Client(api_key=api_key)

    # Fallback to ADC/Vertex mode when service account credentials are set.
    project_id = _load_project_from_adc_file()
    if project_id:
        return modern_genai.Client(vertexai=True, project=project_id, location="us-central1")
    return modern_genai.Client()


def _ensure_legacy_client():
    if genai is None:
        return None
    if settings.GEMINI_API_KEY:
        genai.configure(api_key=settings.GEMINI_API_KEY)
    return genai


def analyze_with_gemini(prompt: str, model: str = None) -> str:
    """Send a prompt to Gemini and return the text response.

    This is a thin wrapper; production use should handle safety, retries,
    and structured parsing of Gemini responses.
    """
    modern_client = _ensure_modern_client()
    legacy_client = _ensure_legacy_client()

    if modern_client is None and legacy_client is None:
        raise RuntimeError(
            "No Gemini SDK available. Install google-genai (preferred) or google-generativeai."
        )

    # Prefer explicit model param, fallback to config.
    if not model:
        model = settings.GEMINI_MODEL

    normalized_model = _normalize_model_name(model)

    # Try a few times with exponential backoff
    last_exc = None
    for attempt in range(1, 4):
        try:
            text = None

            # Preferred modern SDK path.
            if modern_client is not None:
                resp = modern_client.models.generate_content(
                    model=normalized_model,
                    contents=prompt,
                )
                text = getattr(resp, "text", None) or str(resp)

            # Legacy fallback if modern path produced nothing.
            if not text and legacy_client is not None:
                if hasattr(legacy_client, "generate_text"):
                    response = legacy_client.generate_text(model=model, prompt=prompt)
                    text = getattr(response, "text", None) or str(response)
                elif hasattr(legacy_client, "GenerativeModel"):
                    gm = legacy_client.GenerativeModel(normalized_model)
                    response = gm.generate_content(prompt)
                    text = getattr(response, "text", None) or str(response)

            if not text:
                raise RuntimeError("Gemini response was empty.")

            # If model returned something that looks like JSON, extract it
            text = _extract_json_like(text) or text

            return text

        except Exception as e:
            last_exc = e
            # Simple backoff.
            time.sleep(0.5 * attempt)
            continue

    raise RuntimeError(f"Gemini request failed after retries: {last_exc}")


def _extract_json_like(text: str) -> Optional[str]:
    """Try to extract a JSON array or object substring from free text.

    Returns the JSON substring if found, otherwise None.
    """
    import re
    text = text.strip()
    # Quick check: if the whole text is JSON, return it
    try:
        import json

        json.loads(text)
        return text
    except Exception:
        pass

    # Look for first JSON array or object in the text
    m = re.search(r"(\{.*\}|\[.*\])", text, re.DOTALL)
    if m:
        candidate = m.group(1)
        try:
            import json

            json.loads(candidate)
            return candidate
        except Exception:
            return None
    return None
