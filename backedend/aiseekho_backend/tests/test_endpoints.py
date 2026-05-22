# pyrefly: ignore [missing-import]
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_api_root_and_analyze_request_flow():
    root_response = client.get("/")
    assert root_response.status_code == 200
    assert root_response.json()["status"] == "AISeekho Backend Running"

    analyze_payload = {
        "message": "Meri mother ko chest pain hai",
        "location": "Karachi"
    }
    analyze_response = client.post("/analyze-request/", json=analyze_payload)
    assert analyze_response.status_code == 200

    body = analyze_response.json()
    assert body["urgency"] == "HIGH"
    assert body["selected_hospital"] != "No hospital found"
    assert body["booking_id"]
    assert body["hospital_id"]

    booking_id = body["booking_id"]
    booking_response = client.get(f"/simulate-booking/{booking_id}")
    assert booking_response.status_code == 200
    assert booking_response.json()["booking_id"] == booking_id

    cancel_response = client.post(f"/simulate-booking/{booking_id}/cancel")
    assert cancel_response.status_code == 200
    assert cancel_response.json()["booking_status"] == "Cancelled"

    traces_response = client.get("/traces/?urgency=HIGH")
    assert traces_response.status_code == 200
    assert isinstance(traces_response.json(), list)
    assert len(traces_response.json()) >= 1

    trace_id = traces_response.json()[0]["timestamp"]
    trace_detail = client.get(f"/traces/{trace_id}")
    assert trace_detail.status_code == 200
    assert trace_detail.json()["timestamp"] == trace_id
