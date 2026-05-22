from datetime import datetime
from agents.intent import run as intent_run
from agents.provider_discovery import run as provider_run
from agents.decision import run as decision_run
from agents.emergency_coord import run as emergency_run
from agents.execution_simulation import run as execution_run
from agents.followup import run as followup_run
from agents.ops_intel import run as ops_intel_run
from services.mock_store import add_trace


def run_pipeline(message: str, location: str, preferred_time: str = None) -> dict:
    intent_output = intent_run(message, location, preferred_time)
    hospital_output = provider_run(intent_output, intent_output["location"])
    decision_output = decision_run(hospital_output.get("candidates", []), intent_output["urgency"])
    emergency_output = emergency_run(intent_output["urgency"], decision_output.get("selected_hospital", {}))
    execution_output = execution_run(
        decision_output.get("selected_hospital", {}),
        intent_output["urgency"],
        intent_output.get("requested_time", ""),
        intent_output.get("symptom", "Medical issue"),
    )
    followup_output = followup_run(execution_output)
    ops_output = ops_intel_run(hospital_output.get("candidates", []))

    selected = decision_output.get("selected_hospital", {})
    reason_logs = [
        f"[IntentAgent] {intent_output['language']} request parsed as {intent_output['request_type']}.",
        f"[DiscoveryAgent] {hospital_output.get('reason', 'Candidate hospitals prepared.')}",
        f"[DecisionAgent] {decision_output.get('reason', 'Best hospital selected.')}",
        f"[EmergencyAgent] {emergency_output.get('message', 'Emergency check completed.')}",
        f"[ExecutionAgent] {execution_output.get('message', 'Booking simulated.')}",
        f"[FollowUpAgent] {followup_output.get('follow_up', 'Follow-up workflow created.')}",
        f"[OpsIntelAgent] {ops_output.get('reason', 'Operational insight generated.')}",
    ]

    trace_id = datetime.utcnow().isoformat() + "Z"
    trace_record = {
        "timestamp": trace_id,
        "trace_id": trace_id,
        "intent": intent_output,
        "discovery": hospital_output,
        "decision": decision_output,
        "emergency": emergency_output,
        "execution": execution_output,
        "followup": followup_output,
        "ops_intel": ops_output,
        "reasoning_logs": reason_logs,
    }

    # persist trace for later retrieval
    try:
        add_trace(trace_record)
    except Exception:
        pass

    return {
        "urgency": intent_output["urgency"],
        "symptom": intent_output["symptom"],
        "request_type": intent_output["request_type"],
        "requested_time": intent_output.get("requested_time", ""),
        "selected_hospital": selected.get("hospital_name", "No hospital found"),
        "hospital_id": selected.get("hospital_id", "N/A"),
        "distance": selected.get("distance", "N/A"),
        "eta": selected.get("eta", "N/A"),
        "wait_time": selected.get("wait_time", "N/A"),
        "hospital_rating": selected.get("hospital_rating", 0.0),
        "booking_id": execution_output.get("booking_id", "N/A"),
        "reasoning_logs": reason_logs,
        "emergency_note": emergency_output.get("message", ""),
        "ops_insights": ops_output.get("insights", []),
        "follow_up": followup_output.get("follow_up", ""),
        "trace_id": trace_record.get("timestamp"),
        "hospital_lat": selected.get("hospital_lat", 24.8607),
        "hospital_lng": selected.get("hospital_lng", 67.0011),
        "origin_lat": 24.8515,
        "origin_lng": 67.0099,
        "route_polyline": selected.get("route_polyline", "encoded_route_path"),
        "congestion_level": selected.get("congestion_level", "moderate"),
        "traffic_condition": selected.get("traffic_condition", "normal"),
        "vicinity": selected.get("vicinity", location)
    }
