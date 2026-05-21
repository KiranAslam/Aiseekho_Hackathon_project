"""
Simple in-memory booking store for mock persistence during the prototype.
This keeps state within the running process and is not durable.
"""
from datetime import datetime
from typing import List, Dict, Optional

BOOKINGS: List[Dict] = []


def add_booking(record: Dict) -> Dict:
    BOOKINGS.append(record)
    return record


def list_bookings() -> List[Dict]:
    return list(BOOKINGS)


def get_booking(booking_id: str) -> Optional[Dict]:
    for b in BOOKINGS:
        if b.get("booking_id") == booking_id:
            return b
    return None


def get_booking_by_id(booking_id: str) -> Optional[Dict]:
    return get_booking(booking_id)


def update_booking_status(booking_id: str, status: str, note: str = "") -> Optional[Dict]:
    for b in BOOKINGS:
        if b.get("booking_id") == booking_id:
            b["booking_status"] = status
            b["status"] = status
            if note:
                b.setdefault("notes", "")
                b["notes"] = note
            b["updated_at"] = datetime.utcnow().isoformat() + "Z"
            return b
    return None


# Traces storage for agent reasoning and pipeline logs
TRACES: List[Dict] = []


def add_trace(trace: Dict) -> Dict:
    TRACES.append(trace)
    return trace


def list_traces() -> List[Dict]:
    return list(TRACES)


def filter_traces(
    urgency: Optional[str] = None,
    hospital_id: Optional[str] = None,
    since: Optional[str] = None,
    until: Optional[str] = None,
) -> List[Dict]:
    results = []
    parsed_since = None
    parsed_until = None

    def parse_ts(ts: str):
        try:
            return datetime.fromisoformat(ts.replace("Z", ""))
        except Exception:
            return None

    if since:
        parsed_since = parse_ts(since)
    if until:
        parsed_until = parse_ts(until)

    for trace in TRACES:
        if urgency and trace.get("intent", {}).get("urgency", "").upper() != urgency.upper():
            continue
        if hospital_id and trace.get("decision", {}).get("selected_hospital", {}).get("hospital_id", "") != hospital_id:
            continue

        timestamp = parse_ts(trace.get("timestamp", ""))
        if timestamp:
            if parsed_since and timestamp < parsed_since:
                continue
            if parsed_until and timestamp > parsed_until:
                continue

        results.append(trace)

    return results


def get_trace_by_id(trace_id: str) -> Optional[Dict]:
    for trace in TRACES:
        if trace.get("timestamp") == trace_id:
            return trace
    return None


def get_last_trace() -> Optional[Dict]:
    if not TRACES:
        return None
    return TRACES[-1]
