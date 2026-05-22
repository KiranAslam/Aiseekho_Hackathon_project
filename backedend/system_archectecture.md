# Agent Architecture — Rahe-Sehat Healthcare AI

## System Overview
Rahe-Sehat uses a 7-agent pipeline orchestrated via Google Antigravity.
Each agent has a single responsibility and passes its output to the next agent.
The system supports two execution paths: Normal and Emergency.
All agents work fully on rule-based logic. Gemini API is optional.

---

## Execution Paths

### Normal Path
```
A1 (Intent) → A2 (Ops Intel) → A3 (Discovery) → A4 (Ranking) → A6 (Execution) → A7 (Follow-up)
```

### Emergency Path (urgency = HIGH)
```
A1 (Intent) → A5 (Emergency Coord) → A6 (Execution) → A7 (Follow-up)
```

---

## Agent Details

---

### A1 — Intent Understanding Agent
**File:** `agents/intent.py`  
**Responsibility:** Parse raw user input in any language

| Field | Detail |
|-------|--------|
| Input | Raw text string (Urdu / Roman Urdu / English) |
| Output | `{symptom, urgency, language, request_type, location, message}` |
| Default Mode | Rule-based keyword matching |
| Optional | Gemini API for advanced NLP (if GEMINI_API_KEY set) |
| Emergency keywords | chest pain, seena dard, sans nahi, behosh, haadsa, khoon, fori |

**Urgency Levels:**
- `HIGH` — emergency keywords detected → triggers A5
- `MEDIUM` — urgent but not life-threatening
- `LOW` — routine appointment

---

### A2 — Operational Intelligence Agent
**File:** `agents/ops_intel.py`  
**Responsibility:** Analyze hospital load and congestion

| Field | Detail |
|-------|--------|
| Input | List of hospitals from discovery |
| Output | `{insights, top_hospital, congestion_summary, hospitals_analyzed}` |
| Default Mode | Rule-based: wait_time + rating → congestion level |
| Optional | Gemini API for AI-generated insights |

**Congestion Formula:**
- wait ≤ 10 min + rating ≥ 4.0 → **LOW**
- wait ≤ 20 min + rating ≥ 3.0 → **MEDIUM**
- anything else → **HIGH**

---

### A3 — Provider Discovery Agent
**File:** `agents/provider_discovery.py`  
**Responsibility:** Find nearby healthcare providers

| Field | Detail |
|-------|--------|
| Input | `{service_type, location, lat, lng}` |
| Output | List of nearby providers with distance + ETA |
| Primary Source | Google Places API (5km radius) |
| Fallback | Mock JSON — hospitals_karachi.json + hospitals_lahore.json |
| Distance | Haversine formula |

---

### A4 — Decision & Ranking Agent
**File:** `agents/decision.py`  
**Responsibility:** Score and rank providers

| Field | Detail |
|-------|--------|
| Input | Providers list + ops intel data + urgency |
| Output | `{top_provider, ranked_list, reasoning}` |

**Scoring Formula (100 points total):**
| Factor | Weight | Logic |
|--------|--------|-------|
| Distance | 40% | Closest = 40pts, 5km+ = 0pts |
| Availability | 30% | LOW congestion = 30pts |
| Rating | 20% | rating/5 × 20 |
| Urgency match | 10% | Has emergency dept = 10pts |

---

### A5 — Emergency Coordination Agent
**File:** `agents/emergency_coord.py`  
**Responsibility:** Handle life-threatening situations

| Field | Detail |
|-------|--------|
| Input | Intent + providers list |
| Triggered | ONLY when urgency = HIGH |
| Output | `{nearest_er, route_url, eta_minutes, emergency_message}` |
| Routing | Google Directions API |
| Priority | Distance only — speed over everything |

**Behavior:**
- Overrides normal ranking
- Selects nearest emergency-ready hospital
- Generates Google Maps route URL
- Produces urgent confirmation message

---

### A6 — Execution Agent (Booking Simulation)
**File:** `agents/execution_simulation.py`  
**Responsibility:** Simulate end-to-end booking

| Field | Detail |
|-------|--------|
| Input | Selected provider + intent |
| Output | `{booking_id, token, appointment_time, status, message}` |
| Token Format | `EMG{random}` for emergency, `BKG{random}` for normal |
| Storage | In-memory store |

**Booking Response Fields:**
- `booking_status` — Confirmed / Pending
- `booking_id` — Unique booking reference
- `token` — Patient token number
- `appointment_time` — Scheduled slot
- `message` — Confirmation message

---

### A7 — Follow-up & Trace Agent
**File:** `agents/followup.py`  
**Responsibility:** Log agent trace and generate follow-up

| Field | Detail |
|-------|--------|
| Input | All previous agent outputs |
| Output | `{trace_id, timestamp, intent, discovery, booking, follow_up_message}` |
| Storage | In-memory trace store |
| Endpoints | GET /traces/ and GET /traces/last |

---

## API Endpoints

| Method | Endpoint | Agents Used |
|--------|----------|-------------|
| POST | `/analyze-request/` | A1→A2→A3→A4/A5→A6→A7 |
| POST | `/simulate-booking/` | A6 |
| GET | `/simulate-booking/all` | — |
| GET | `/hospital-analytics/` | A2 |
| GET | `/hospital-analytics/insights` | A2 |
| GET | `/traces/` | A7 |
| GET | `/traces/last` | A7 |
| GET | `/docs` | Swagger UI |

---

## Data Flow

```
[User Input]
     |
     ▼
[A1 Intent Agent] ── rule-based (Gemini optional)
     |
     ├── urgency=HIGH ──→ [A5 Emergency Agent] ── Google Directions API
     |                           |
     └── urgency=LOW/MED         |
           |                     |
           ▼                     |
    [A2 Ops Intel] ── rule-based (Gemini optional)
           |                     |
           ▼                     |
    [A3 Discovery] ── Google Places API / Mock JSON
           |                     |
           ▼                     |
    [A4 Ranking] ←───────────────+
           |
           ▼
    [A6 Execution] ── In-memory booking store
           |
           ▼
    [A7 Follow-up] ── Trace store
           |
           ▼
    [API Response → Flutter App]
```

---

## Team

| Member | Role |
|--------|------|
| Kiran Aslam | AI Developer — Python backend, agents, FastAPI, Google Cloud |
| Aqsa Siddiqui | Flutter Developer — Mobile frontend, UI/UX, Google Maps |

---

## Error Handling Strategy
Every agent has try/except with fallback:
- Places API fails → mock JSON dataset loads automatically
- No hospitals found → nearest major hospital recommended
- Invalid input → defaults to general physician search
- Any agent crash → returns safe fallback response, pipeline continues