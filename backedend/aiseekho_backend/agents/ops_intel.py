# Agent 3 — Operational Intelligence Agent
# Analyzes hospital availability, congestion, and emergency readiness
from config import settings
import json

try:
    from services.gemini_service import analyze_with_gemini
except Exception:
    analyze_with_gemini = None


def _calculate_congestion(hospital: dict) -> str:
    """Calculate congestion level from wait_time and rating."""
    try:
        wait_raw = hospital.get("wait_time", "15 mins")
        wait_mins = int(str(wait_raw).split()[0])
        rating = float(hospital.get("hospital_rating", 3.0))

        if wait_mins <= 10 and rating >= 4.0:
            return "LOW"
        elif wait_mins <= 20 and rating >= 3.0:
            return "MEDIUM"
        else:
            return "HIGH"
    except Exception:
        return "MEDIUM"


def run(hospitals: list) -> dict:
    if not hospitals:
        return {
            "agent": "OpsIntelAgent",
            "insights": [],
            "reason": "No hospital data available for analysis."
        }

    # Add congestion_level to every hospital
    for h in hospitals:
        if h.get("congestion_level", "UNKNOWN") == "UNKNOWN":
            h["congestion_level"] = _calculate_congestion(h)

    # If live and Gemini configured, ask LLM to produce concise insights
    if settings.APP_MODE == "live" and analyze_with_gemini and settings.GEMINI_API_KEY:
        try:
            summary = []
            for h in hospitals:
                summary.append(
                    f"{h.get('hospital_name')} ("
                    f"rating: {h.get('hospital_rating')}, "
                    f"eta: {h.get('eta')}, "
                    f"wait: {h.get('wait_time')}, "
                    f"congestion: {h.get('congestion_level')})"
                )
            prompt = (
                "Given the following hospitals and their stats, produce a JSON array "
                "of 3 short insights about which hospital to pick and why. "
                "Return only JSON.\n\nHospitals:\n" + "\n".join(summary)
            )
            resp = analyze_with_gemini(prompt)
            insights = json.loads(resp)
            top = insights[0] if insights else hospitals[0].get("hospital_name")
            return {
                "agent": "OpsIntelAgent",
                "insights": insights,
                "top_hospital": top,
                "hospitals_analyzed": hospitals,
                "reason": "Operational intelligence completed via Gemini."
            }
        except Exception:
            pass

    # Fallback — manual analysis
    best_rating = max(hospitals, key=lambda h: h.get("hospital_rating", 0))
    fastest_eta = min(
        hospitals,
        key=lambda h: int(str(h.get("eta", "999 mins")).split()[0])
    )
    low_congestion = [h for h in hospitals if h.get("congestion_level") == "LOW"]

    insights = [
        f"Best-rated hospital is {best_rating['hospital_name']} "
        f"with rating {best_rating['hospital_rating']} "
        f"and {best_rating['congestion_level']} congestion.",

        f"Fastest arrival is {fastest_eta['hospital_name']} "
        f"at {fastest_eta['eta']} with {fastest_eta['congestion_level']} congestion.",

        f"{len(low_congestion)} hospital(s) have LOW congestion and are immediately available."
        if low_congestion else
        "All hospitals are experiencing MEDIUM to HIGH congestion right now.",
    ]

    return {
        "agent": "OpsIntelAgent",
        "insights": insights,
        "top_hospital": best_rating["hospital_name"],
        "hospitals_analyzed": hospitals,
        "congestion_summary": {
            "LOW": len([h for h in hospitals if h.get("congestion_level") == "LOW"]),
            "MEDIUM": len([h for h in hospitals if h.get("congestion_level") == "MEDIUM"]),
            "HIGH": len([h for h in hospitals if h.get("congestion_level") == "HIGH"]),
        },
        "reason": "Operational intelligence completed."
    }