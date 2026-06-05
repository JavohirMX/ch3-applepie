# Conversa

**AI-powered communication tool for deaf and hard-of-hearing travelers at airports**

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![UI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)
![Backend](https://img.shields.io/badge/backend-FastAPI-009688)
![Status](https://img.shields.io/badge/status-in--progress-yellow)
![Team](https://img.shields.io/badge/team-Apple_Pi-orange)

**Team Apple Pi** (π + pie): Aryan, Aulia, Hans, Sakinah, John

Conversa enables fast, natural communication between deaf travelers and airport staff. It transcribes speech in real time, uses AI to suggest context-aware replies you can tap to respond, and flips your response to a large readable display for the other person.

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

### 2. Run the iOS app

Privacy usage strings (microphone, speech recognition, camera, photo library) are configured in the **conversa** Xcode target build settings.

1. Open `conversa/conversa.xcodeproj` in Xcode
2. Select scheme: **conversa**
3. Choose an iOS Simulator or physical device (recommended for speech recognition)
4. Press **Run** (⌘R)

See [conversa/README.md](./conversa/README.md) for the full iOS app flow, architecture, and manual test checklist.

### 3. Backend (optional)

The iOS app does not require the backend for local transcription today. To run the API:

```bash
cd backend
# see backend/README.md
```

### First launch (iOS)

1. **Onboarding** — two intro pages (Skip or Start)
2. **Setup** — personal preferences → upload ticket → confirm ticket info (once)
3. **Home** — continue or start a new journey
4. **Transcription** — tap mic for live speech-to-text; use the text sheet to compose replies and Flip Text

---

## Project Structure

```
ch3-applepie/
├── backend/                          # FastAPI backend
│   ├── app/
│   │   ├── main.py
│   │   ├── routers/                  # /users, /chats, /messages, /forms
│   │   └── services/
│   ├── alembic/
│   ├── docker-compose.yml
│   └── README.md
│
├── conversa/                         # iOS app (SwiftUI)
│   ├── conversa.xcodeproj/
│   ├── README.md                     # Detailed iOS docs
│   └── conversa/
│       ├── App/                      # conversaApp, RootView
│       ├── Navigation/               # MainFlowView, routes
│       ├── Services/                 # SpeechService, JourneyStore
│       ├── Features/
│       │   ├── Onboarding/
│       │   ├── Setup/                # Preferences, ticket upload
│       │   ├── Home/
│       │   ├── Settings/
│       │   ├── Transcription/        # Mic, live STT, TextSheet
│       │   └── FlipText/
│       ├── Components/
│       └── DesignSystem/
│
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

All endpoints prefixed with `/api`. See [backend/README.md](./backend/README.md) for setup and API details.

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
- Physical device recommended for speech recognition (Simulator is unreliable)
- iOS backend client not wired yet — transcription and journey data are local (`JourneyStore`)

---

## Roadmap

### iOS

- [x] Onboarding and first-run setup (preferences, ticket upload)
- [x] Home hub and Settings
- [x] Transcription screen with mic and live STT
- [x] Text sheet with suggestions and Flip Text
- [x] On-device text-to-speech (`SpeechService`, UI not wired)
- [ ] Backend API integration (device register, chats, AI suggestions)
- [ ] Real boarding pass OCR
- [ ] Text-to-speech button in UI
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] XCTest unit + UI test suite

### Backend

- [x] FastAPI + PostgreSQL API
- [x] AI reply suggestions endpoint
- [ ] Full iOS client integration

---

## Vision

Conversa removes communication barriers at airports by combining real-time speech transcription, AI-powered reply suggestions, and optional text-to-speech — enabling deaf and hard-of-hearing travelers to communicate with airport staff independently, confidently, and without typing.
