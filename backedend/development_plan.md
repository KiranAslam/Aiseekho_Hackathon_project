# AI Healthcare Orchestration Platform  — Development Plan (Antigravity)

## Project Overview
**Name:** Rah-e-Sehat AI Healthcare Orchestration Platform  
**Hackathon:** AiSeekho Google Antigravity Hackathon 2026  
**Track:** Challenge 2 — AI Service Orchestrator for Informal Economy  
**Theme:** Pakistan's first autonomous healthcare operations intelligence layer  

---

## Problem Being Solved
Pakistan's healthcare ecosystem is fragmented and manually operated.
Patients rely on WhatsApp groups, phone calls, and personal referrals to find doctors.
This leads to:
- Delayed treatment in emergencies
- Hospital overcrowding and poor load distribution
- No real-time provider availability
- Language barriers (Urdu, Roman Urdu, English)

---

## Solution Designed
An Agentic AI system that:
1. Understands healthcare requests in Urdu / Roman Urdu / English
2. Detects emergency vs normal requests automatically
3. Discovers nearby providers using Google Places API
4. Ranks providers using weighted intelligence scoring
5. Simulates end-to-end booking with token generation
6. Logs full agent trace for transparency

---

## Antigravity Usage
Google Antigravity was used as the core orchestration and development assistant:
- Designed the multi-agent pipeline architecture
- Generated implementation plans for each agent
- Reviewed agent logic and suggested improvements
- Assisted in debugging FastAPI endpoint errors
- Generated test cases for intent understanding and booking flow
- Produced walkthrough documentation for the agentic workflow

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.11 + FastAPI |
| AI / LLM | Gemini API |
| Provider Discovery | Google Places API (Real) |
| Emergency Routing | Google Directions API (Real) |
| Hospital Data | Mock JSON (Karachi + Lahore hospitals) |
| Frontend | Flutter (Mobile App) |
| Orchestration Planning | Google Antigravity |

---

## Agent Workflow Planned

### Normal Request Flow
```
User Input (Urdu / Roman Urdu / English)
        ↓
A1 — Intent Understanding Agent
        ↓
A2 — Operational Intelligence Agent (Hospital Load)
        ↓
A3 — Provider Discovery Agent (Places API)
        ↓
A4 — Decision & Ranking Agent (Weighted Score)
        ↓
A6 — Execution Agent (Booking Simulation)
        ↓
A7 — Follow-up & Trace Agent
```

### Emergency Request Flow
```
User Input → emergency keywords detected
        ↓
A1 — Intent Agent (urgency = HIGH)
        ↓
A5 — Emergency Coordination Agent (override ranking)
        ↓
A6 — Execution Agent (immediate booking)
        ↓
A7 — Follow-up & Trace Agent
```

---

## APIs Used

| API | Purpose | Type |
|-----|---------|------|
| Google Places API | Nearby hospital discovery | Real |
| Google Directions API | Emergency route + ETA | Real |
| Gemini API | NLP intent parsing | Real |
| Mock hospital JSON | Fallback provider data (Karachi + Lahore) | Mock |

> **Note:** System is designed to work fully without Gemini API.
> Rule-based logic handles intent parsing, congestion analysis,
> and ranking when Gemini is not configured.

---

## Milestones

| Milestone | Status |
|-----------|--------|
| Project structure scaffold | Done |
| Mock hospital data created (Karachi + Lahore) | Done |
| A1 Intent Agent built | Done |
| A2 Ops Intel Agent built | Done |
| A3 Provider Discovery built | Done |
| A4 Ranking / Decision Agent built | Done |
| A5 Emergency Coordination Agent built | Done |
| A6 Execution / Booking Simulation built | Done |
| A7 Follow-up & Trace Agent built | Done |
| FastAPI endpoints working | Done |
| Swagger UI documentation | Done |
| GitHub repository published | Done |
| Flutter frontend integration | Done |
| Demo video recorded | Done |

---

## Team

| Member | Role |
|--------|------|
| Kiran Aslam | AI Developer — Python backend, agents, FastAPI, Google Cloud |
| Aqsa Siddiqui | Flutter Developer — Mobile frontend, UI/UX, Google Maps integration |

---

## Key Design Decisions
1. **Fallback first** — every agent falls back to mock data if API fails
2. **Language agnostic** — supports Urdu, Roman Urdu, English input
3. **Emergency override** — urgency=HIGH skips ranking, goes direct to nearest ER
4. **Full trace logging** — every agent step logged with timestamp and duration
5. **Swagger UI** — complete API documentation auto-generated at /docs