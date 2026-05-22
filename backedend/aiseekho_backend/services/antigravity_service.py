"""antigravity_service.py — Skeleton wrapper for Google Antigravity orchestration

This module provides a thin adapter layer for integrating Antigravity.
Actual Antigravity SDK/endpoint details are required to implement full
orchestration. For now it exposes a small interface and raises informative
errors when not configured.
"""
from typing import Dict, Any
from config import settings


def start_workflow(workflow_name: str, inputs: Dict[str, Any]) -> Dict[str, Any]:
    """Trigger an Antigravity workflow. Returns a dict with run metadata.

    NOTE: This is a placeholder. Provide Antigravity endpoint/credentials
    to implement real orchestration.
    """
    raise NotImplementedError("Antigravity integration not configured. Provide access details to enable.")


def get_workflow_status(run_id: str) -> Dict[str, Any]:
    raise NotImplementedError("Antigravity integration not configured.")
