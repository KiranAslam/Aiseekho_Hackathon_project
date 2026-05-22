# Agent 5 — Emergency Coordination Agent
# Handles emergency escalation and urgent routing

def run(urgency: str, selected_hospital: dict) -> dict:
    emergency_ready = selected_hospital.get("emergency_ready", False)
    hospital_name = selected_hospital.get("hospital_name", "Unknown Hospital")
    if urgency == "HIGH":
        if emergency_ready:
            return {
                "agent": "EmergencyCoordAgent",
                "priority": "HIGH",
                "emergency_mode": True,
                "message": f"{hospital_name} is emergency-ready and selected for urgent care.",
                "next_step": "Proceed to booking and immediate coordination."
            }
        return {
            "agent": "EmergencyCoordAgent",
            "priority": "HIGH",
            "emergency_mode": False,
            "message": f"{hospital_name} is not emergency-ready. Recommend escalation to alternate emergency facility.",
            "next_step": "Flag emergency routing and notify user of limited emergency capacity."
        }

    return {
        "agent": "EmergencyCoordAgent",
        "priority": urgency,
        "emergency_mode": False,
        "message": f"Standard care path selected for {hospital_name}.",
        "next_step": "Proceed with booking simulation."
    }
