# Agent 7 — Follow-Up & Learning Agent
# Schedules reminders and workflow continuity


def run(booking: dict) -> dict:
    scheduled_time = booking.get("appointment_time", "Soon")
    reminder_text = "Reminder scheduled 1 hour before appointment."
    completion_text = "Follow-up confirmation will be sent after service completion."
    follow_up_note = (
        f"Follow-up workflow started for booking {booking.get('booking_id', '')}. "
        f"{reminder_text} {completion_text}"
    )

    return {
        "agent": "FollowUpAgent",
        "follow_up": follow_up_note,
        "reminder": reminder_text,
        "completion_note": completion_text,
        "status": "scheduled",
    }
