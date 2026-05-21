# POST /simulate-booking — Step 4 implementation

from fastapi import APIRouter, HTTPException
from models.request_models import BookingRequest
from models.response_models import BookingResponse
from services.mock_data import get_hospital_by_id
from agents.execution_simulation import run as execute_booking
from services.mock_store import get_booking, list_bookings
from typing import List

router = APIRouter(prefix="/simulate-booking", tags=["Booking"])


@router.post("/", response_model=BookingResponse)
def simulate_booking(body: BookingRequest):
    hospital = get_hospital_by_id(body.hospital_id)
    if hospital is None:
        raise HTTPException(status_code=404, detail="Hospital not found")

    booking = execute_booking(
        hospital,
        body.urgency,
        body.requested_time or "",
        "Healthcare Service",
    )

    stored = get_booking(booking["booking_id"])
    if stored is None:
        # booking was created but not persisted
        # return the in-memory booking response as fallback
        stored = booking

    return {
        "booking_status": stored.get("booking_status", "Confirmed"),
        "booking_id": stored.get("booking_id", "N/A"),
        "appointment_time": stored.get("appointment_time", "N/A"),
        "token": stored.get("token", None),
        "hospital_name": stored.get("provider_name", "Unknown"),
    }


@router.get("/all")
def get_all_bookings():
    return list_bookings()


@router.get("/{booking_id}", response_model=BookingResponse)
def get_booking_by_id(booking_id: str):
    booking = get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return {
        "booking_status": booking.get("booking_status", "Unknown"),
        "booking_id": booking["booking_id"],
        "appointment_time": booking.get("appointment_time", "N/A"),
        "token": booking.get("token"),
        "hospital_name": booking.get("provider_name", "Unknown"),
    }


@router.post("/{booking_id}/cancel", response_model=BookingResponse)
def cancel_booking(booking_id: str):
    from services.mock_store import update_booking_status

    updated = update_booking_status(booking_id, "Cancelled", "Cancelled by user/API")
    if not updated:
        raise HTTPException(status_code=404, detail="Booking not found")
    return {
        "booking_status": updated.get("booking_status", "Cancelled"),
        "booking_id": updated["booking_id"],
        "appointment_time": updated.get("appointment_time", "N/A"),
        "token": updated.get("token"),
        "hospital_name": updated.get("provider_name", "Unknown"),
    }
