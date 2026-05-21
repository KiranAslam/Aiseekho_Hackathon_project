# Agent 4 — Decision & Optimization Agent
# Ranks hospitals and explains WHY one was selected over another


def _select_best_hospital(candidates: list) -> dict:
    best = min(candidates, key=lambda item: item.get("score", 9999))
    return best


def run(hospitals_with_intel: list, urgency: str) -> dict:
    if not hospitals_with_intel:
        return {
            "agent": "DecisionOptimizationAgent",
            "selected_hospital": {},
            "reason": "No hospitals available to evaluate.",
            "ranked_hospitals": []
        }

    selected = _select_best_hospital(hospitals_with_intel)
    reason = (
        f"Selected {selected['hospital_name']} because it has the lowest combined congestion, wait time, "
        f"and fastest available routing for {urgency.lower()} cases."
    )

    return {
        "agent": "DecisionOptimizationAgent",
        "selected_hospital": selected,
        "reason": reason,
        "ranked_hospitals": hospitals_with_intel
    }
