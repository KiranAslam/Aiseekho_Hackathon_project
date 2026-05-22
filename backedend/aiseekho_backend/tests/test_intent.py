from agents.intent import run as intent_run


def test_intent_detects_high_urgency_for_chest_pain():
    result = intent_run("Meri mother ko chest pain hai", "Karachi", None)

    assert result["urgency"] == "HIGH"
    assert "chest" in result["symptom"].lower() or result["request_type"] in ["Emergency", "Acute"]
    assert result["location"] == "Karachi"
