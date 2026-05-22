# trace_logger.py — Builds Antigravity-style reasoning traces

from loguru import logger

def log_trace(agent_name: str, message: str) -> str:
    entry = f"[{agent_name}] {message}"
    logger.info(entry)
    return entry

def build_trace_log(entries: list) -> list:
    return [f"[{e['agent']}] {e['message']}" for e in entries]
