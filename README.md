# Conversa

**AI-powered communication tool for deaf and hard-of-hearing travelers at airports**

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![UI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)
![Backend](https://img.shields.io/badge/backend-FastAPI-009688)
![Status](https://img.shields.io/badge/status-in--progress-yellow)
![Team](https://img.shields.io/badge/team-AERES-orange)

**Team:** John, Aryan, Hans, Sakina, Aulia

Conversa is an iOS app that enables fast, natural communication between deaf travelers and airport staff. It transcribes speech in real time, uses AI to suggest context-aware replies you can tap to respond, and flips your response to a large readable display for the other person.

---

## What Conversa Does

Deaf and hard-of-hearing travelers currently rely on typing notes or text messages to communicate with hearing people at airports. This is **slow, effortful, and frustrating for both sides**.

Conversa removes that friction:

| Feature | How it works |
|---|---|
| **Live transcription** | Airport staff speaks → words appear on screen in real time, large readable font |
| **AI reply suggestions** | App analyzes context → shows 3-4 natural, tappable reply chips in a slide-up sheet |
| **Flip Text** | Tap a suggestion → large full-screen display for the other person to read, rotated 180° |
| **Text-to-speech** | Optional — app reads your reply aloud in a clear voice |
| **Context setup** | Provide your flight details before arriving at the counter or gate |
| **Text size control** | Adjustable text sizes for accessibility |

---

## Core Use Case: Airport Communication

```
1. SET UP
   └── Provide flight context: gate, flight number, destination

2. STAFF SPEAKS
   ├── You tap the microphone
   └── Their words appear on screen in real time, large font

3. AI SUGGESTS REPLIES
   ├── Reply sheet slides up
   └── Shows 3-4 tappable response chips based on what was said
       ["Thank you, what time is boarding?",
        "Is the flight delayed?",
        "Can you help me find gate B42?"]

4. YOU TAP A REPLY
   └── Selected text appears in the response area

5. DELIVER YOUR RESPONSE
   ├── Flip Text — rotated full-screen display for staff to read, OR
   └── Speak — app reads it aloud
```

---

## Screen Layout

**Main screen** — transcription only, always visible:

```
┌──────────────────────────┐
│                          │
│  ┌────────────────────┐  │
│  │                    │  │
│  │  Transcription     │  │  ← Large text (24pt+)
│  │  "Your flight      │  │     Latest speech-to-text
│  │   BA112 is delayed │  │
│  │   30 minutes..."   │  │
│  │                    │  │
│  └────────────────────┘  │
│                          │
│              🗣️          │  ← Mic button (tap to listen)
│                          │
│     [ 💬 Reply ]         │  ← Opens reply sheet
└──────────────────────────┘
```

**Reply sheet** — slides up to respond:

```
┌──────────────────────────┐
│  ┌────────────────────┐  │
│  │ ✏️ Your response...│  │  ← Editable text field
│  └────────────────────┘  │
│                          │
│  ┌────────────────────┐  │
│  │ Suggestion 1       │  │  ← AI-generated chips
│  │ Suggestion 2       │  │     Tap to fill the field
│  │ Suggestion 3       │  │
│  │ Suggestion 4       │  │
│  └────────────────────┘  │
│                          │
│  [ 🔄 Flip ] [ 🔊 Speak ]│  ← Deliver your response
└──────────────────────────┘
```

---

## Features

### Context Setup

Provide your situation before the interaction:

- **Flight details** — Airline, flight number, gate, destination
- **Quick presets** — Check-in, security, boarding, baggage claim, customer service
- **Boarding pass scan** — Upload a photo for OCR (coming soon)

### Speech-to-Text

- Real-time transcription with low latency
- Large readable text display (24pt minimum, adjustable)
- Works in noisy airport environments
- Multi-language support

### AI Reply Suggestions

- Analyzes what was just said + your flight context
- Generates 3-4 natural language response options
- Presented as tappable chips in the reply sheet
- Full sentences (not keywords), matching natural speech

### Flip Text

- Shows your response in large, clear font filling the screen
- Rotated 180° for the other person to read
- High contrast, easy to read at a glance
- Tap to dismiss

### Text-to-Speech

- Reads your response aloud in a clear voice
- Useful when staff can't easily read the screen

### Text Size Control

- Slider or preset sizes (Small / Medium / Large / Extra Large)
- Persistent across sessions
- Dynamic Type support (iOS native)

---

## Design Principles

1. **Speed first** — Every interaction faster than typing
2. **One tap, one action** — Minimize steps to communicate
3. **Accessibility by default** — Large text, high contrast, VoiceOver
4. **Privacy conscious** — Conversations are sensitive; minimize data collection
5. **Works when you need it** — Reliable, clear UX under stress
6. **Respectful** — Empowers the user

---

## Tech Stack

| Component | Technology |
|---|---|
| iOS UI | SwiftUI, iOS 26+ |
| State management | `@Observable` (Swift Observation) |
| Networking | Swift Concurrency (`async/await` + `URLSession`) |
| Speech-to-text | `Speech` framework (`SFSpeechRecognizer`) |
| Text-to-speech | `AVFAudio` (`AVSpeechSynthesizer`) |
| Document OCR | VisionKit / `VNDocumentCameraViewController` |
| Device identity | Keychain Services |
| Backend framework | FastAPI (Python 3.12+) |
| Database | PostgreSQL 17 + SQLAlchemy async + Alembic |
| AI / LLM | OpenAI-compatible API (GPT-4o-mini, or any provider via `LLM_BASE_URL`) |
| Infrastructure | Docker Compose (API + DB) |

---

## Quick Start

### 1. Start the backend

```bash
cd backend

export LLM_API_KEY=sk-your-key-here
export LLM_MODEL=gpt-4o-mini

docker compose up -d
docker compose exec api alembic upgrade head

curl http://localhost:8000/health
# → {"status": "ok"}
```

### 2. Add privacy keys in Xcode

In Xcode, select the **CH3** target → **Info** tab and add:

| Key | Value |
|---|---|
| `Privacy - Speech Recognition Usage Description` | `Conversa uses speech recognition to transcribe what people say to you in real time.` |
| `Privacy - Microphone Usage Description` | `Conversa needs the microphone to capture speech for live transcription.` |

### 3. Run

1. Select scheme: **CH3**
2. Choose an iOS Simulator (iPhone 16+)
3. Press **Run** (⌘R)

### First launch

1. App generates a UUID → stores in Keychain
2. Registers device with backend: `POST /api/users/register`
3. Enter your flight context
4. Tap the mic when someone speaks → live transcription appears
5. Tap Reply → AI suggestions appear → tap one to select
6. Flip Text or Speak to deliver your response

---

## Project Structure

```
ch3-applepie/
├── backend/                          # FastAPI backend
│   ├── app/
│   │   ├── main.py                   # App setup, CORS, router mounting
│   │   ├── config.py                 # Settings from env vars
│   │   ├── database.py               # Async SQLAlchemy engine
│   │   ├── dependencies.py           # Auth guards (X-Device-Id)
│   │   ├── models/                   # SQLAlchemy ORM entities
│   │   ├── schemas/                  # Pydantic request/response schemas
│   │   ├── routers/                  # /users, /chats, /messages, /forms
│   │   └── services/                 # Business logic + OpenAI client
│   ├── alembic/                      # DB migrations
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
│
├── CH3/                              # iOS app (rebuilding from scratch)
│   ├── CH3.xcodeproj/
│   └── CH3/
│       ├── Networking/               # HTTP layer (APIClient, env, errors)
│       ├── Services/                 # API + platform (Speech, User, Chat, Form)
│       ├── Models/                   # DTOs, domain models, state
│       ├── Features/
│       │   ├── Home/                 # Entry point + context setup
│       │   ├── Transcription/        # Main transcription screen + mic
│       │   ├── ReplySheet/           # Reply sheet with text field + chips
│       │   └── FlipText/             # Full-screen flipped text display
│       ├── Components/               # Reusable UI pieces
│       └── DesignSystem/             # Colors, typography, spacing
│
├── INTEGRATION.md                    # API reference, data flow, troubleshooting
└── README.md
```

---

## Architecture

```mermaid
flowchart TB
    subgraph iOS["iOS App (SwiftUI)"]
        Home["Home / Context Setup"]
        Trans ["Transcription Screen"]
        Sheet["Reply Sheet\n(Suggestions + Text)"]
        FlipV["Flip Text View"]
        Speech["SpeechService\n(STT + TTS)"]
        APIClient["APIClient (actor)\nURLSession + JSON"]
        Keychain["DeviceIdentityService\n(Keychain UUID)"]
    end

    subgraph Backend["Backend (FastAPI)"]
        Routers["Routers\n/users /chats /messages /forms"]
        SvcBackend["Services\n(chat, message, openai)"]
        DB[("PostgreSQL 17")]
    end

    subgraph External["External"]
        LLM["OpenAI-compatible LLM\n(GPT-4o-mini)"]
    end

    Home --> Trans
    Trans --> Sheet
    Sheet --> FlipV
    Trans --> Speech
    Sheet --> Speech
    APIClient --> Keychain
    Sheet --> APIClient
    Home --> APIClient
    APIClient -- "HTTPS + JSON\nX-Device-Id header" --> Routers
    Routers --> SvcBackend
    SvcBackend --> DB
    SvcBackend --> LLM
    Speech -- "SFSpeechRecognizer\nAVSpeechSynthesizer" --> Trans
```

### Data flow

| Action | Flow |
|---|---|
| **App launch** | Keychain UUID → `POST /api/users/register` → ready |
| **Set context** | Flight details → `POST /api/chats` |
| **Staff speaks** | 🎤 tap → `SFSpeechRecognizer` → live transcription on screen |
| **AI suggests** | `POST /api/chats/{id}/suggestions` → chips in reply sheet |
| **Deliver response** | Flip Text (rotated full-screen) or Speak (TTS) |

---

## API Surface

All endpoints prefixed with `/api`. Full reference in [INTEGRATION.md](./INTEGRATION.md).

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/users/register` | Register device (idempotent) |
| `GET` | `/api/chats` | List user's sessions |
| `POST` | `/api/chats` | Create session with context |
| `GET` | `/api/chats/{id}` | Get single session |
| `DELETE` | `/api/chats/{id}` | Soft-delete session |
| `GET` | `/api/chats/{id}/messages` | Paginated transcription history |
| `POST` | `/api/chats/{id}/messages` | Save transcription + get AI reply |
| `GET` | `/api/forms/{type}` | Get form definition |
| `POST` | `/api/chats/{id}/suggestions` | Generate reply chips |

---

## Testing & Limitations

- No XCTest target configured yet
- Backend requires a running PostgreSQL instance and LLM API key
- Physical device needed for speech recognition (simulator not supported)
- Physical device needs the Mac's IP in `APIEnvironment.swift`

---

## Roadmap

- [x] On-device speech-to-text with live transcription
- [x] On-device text-to-speech
- [x] AI reply suggestions (context-aware)
- [x] Backend API (FastAPI + PostgreSQL)
- [x] Device identity via Keychain
- [ ] Transcription screen with mic FAB
- [ ] Reply sheet with suggestions + text field
- [ ] Flip Text — rotated full-screen display
- [ ] Context setup (flight details + presets)
- [ ] Boarding pass / ticket upload (document OCR)
- [ ] Text size adjustment controls
- [ ] Multi-language support
- [ ] Accessibility audit (VoiceOver, Dynamic Type, high contrast)
- [ ] XCTest unit + UI test suite
- [ ] CI pipeline

---

## Vision

Conversa removes communication barriers at airports by combining real-time speech transcription, AI-powered reply suggestions, Flip Text display, and optional text-to-speech — enabling deaf and hard-of-hearing travelers to communicate with airport staff independently, confidently, and without typing.
