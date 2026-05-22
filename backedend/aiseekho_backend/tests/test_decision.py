from agents.decision import run as decision_run


def test_decision_selects_lowest_score_hospital():
    candidates = [
        {"hospital_id": "H1", "hospital_name": "Alpha", "score": 50},
        {"hospital_id": "H2", "hospital_name": "Beta", "score": 30},
        {"hospital_id": "H3", "hospital_name": "Gamma", "score": 70},
    ]

    result = decision_run(candidates, "HIGH")

    assert result["selected_hospital"]["hospital_id"] == "H2"
    assert "lowest combined congestion" in result["reason"]
    assert result["ranked_hospitals"] == candidates
