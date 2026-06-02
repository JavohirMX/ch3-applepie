# Conversa iOS ↔ Backend Integration

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Data Flow](#data-flow)
4. [API Reference](#api-reference)
5. [Authentication Model](#authentication-model)
6. [iOS Networking Stack](#ios-networking-stack)
7. [Model Mapping](#model-mapping)
8. [Error Handling](#error-handling)
9. [State Management](#state-management)
10. [Setup & Running](#setup--running)
11. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                     │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │  Views    │  │  Store   │  │    Service Layer      │  │
│  │          │  │          │  │                       │  │
│  │ Home     │  │ ChatStore│  │ UserService           │  │
│  │ ChatList │──│ @Observable│──│ ChatService           │  │
│  │ Context  │  │          │  │ MessageService        │  │
│  │ Conv     │  │          │  │ FormService           │  │
│  └──────────┘  └──────────┘  │                       │  │
│                               │         ┌───────────┐ │  │
│                               │────────▶│APIClient  │ │  │
│                               │         │(actor)    │ │  │
│                               │         │           │ │  │
│                               │         │- URLSession│ │  │
│                               │         │- JSON codec│ │  │
│                               │         │- X-Device-Id│ │  │
│                               └─────────┴─────┬─────┘ │  │
│                                               │        │
│                         ┌─────────────────────┘        │
│                         │ DeviceIdentityService         │
│                         │ (Keychain UUID)               │
│                         └──────────────────────────────┘
└──────────────────────────────────┬──────────────────────┘
                                   │ HTTPS + JSON
                                   ▼
┌─────────────────────────────────────────────────────────┐
│                  Backend (FastAPI)                        │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ Routers  │  │ Services │  │    External           │  │
│  │          │  │          │  │                       │  │
│  │ /users   │  │ chat     │  │  OpenAI-compatible    │  │
│  │ /chats   │──│ message  │──│  LLM API              │  │
│  │ /messages│  │ openai   │  │  (GPT-4o-mini etc.)   │  │
│  │ /forms   │  │ forms    │  │                       │  │
│  └──────────┘  └────┬─────┘  └──────────────────────┘  │
│                     │                                    │
│              ┌──────▼──────┐                            │
│              │  PostgreSQL │                            │
│              │  (asyncpg)  │                            │
│              └─────────────┘                            │
└─────────────────────────────────────────────────────────┘
```

### Key design decisions

| Decision | Choice | Rationale |
|---|---|---|
| iOS networking | Swift Concurrency (`async/await`) | Native, no dependencies, modern Swift |
| HTTP client | `actor APIClient` wrapping `URLSession.shared` | Thread-safe singleton, serializes mutations |
| Auth mechanism | `X-Device-Id` header with Keychain-stored UUID | No user accounts needed; survives reinstalls |
| State management | `@Observable` `ChatStore` | iOS 17+ native observation, minimal boilerplate |
| JSON coding | `.convertFromSnakeCase` strategy | Seamless mapping to Python/snake_case backend |
| Backend framework | FastAPI + SQLAlchemy async | High performance, auto OpenAPI docs, typed schemas |
| LLM integration | OpenAI-compatible client | Provider-agnostic; works with OpenAI, OpenRouter, etc. |

---

## Project Structure

```
ch3-applepie/
├── backend/                          # FastAPI backend
│   ├── app/
│   │   ├── main.py                   # App setup, CORS, router mounting
│   │   ├── config.py                 # Pydantic settings (env vars)
│   │   ├── database.py               # Async SQLAlchemy engine + session
│   │   ├── dependencies.py           # get_current_user, get_owned_chat
│   │   ├── seed.py                   # Sample data seeder
│   │   ├── models/
│   │   │   ├── user.py               # User ORM model
│   │   │   ├── chat.py               # Chat ORM model + CategoryType/FormType enums
│   │   │   └── message.py            # Message ORM model + MessageSender enum
│   │   ├── schemas/
│   │   │   ├── user.py               # Pydantic request/response schemas
│   │   │   ├── chat.py
│   │   │   ├── message.py
│   │   │   └── form.py
│   │   ├── routers/
│   │   │   ├── users.py              # POST /api/users/register, GET/PATCH /api/users/{id}
│   │   │   ├── chats.py              # GET/POST /api/chats, GET/DELETE /api/chats/{id}
│   │   │   ├── messages.py           # GET/POST /api/chats/{id}/messages
│   │   │   └── forms.py              # GET /api/forms/{type}, POST /api/chats/{id}/suggestions
│   │   └── services/
│   │       ├── chat_service.py       # CRUD business logic
│   │       ├── message_service.py    # Message save + AI reply orchestration
│   │       ├── openai_service.py     # LLM client wrapper
│   │       └── form_definitions.py   # Static form step definitions
│   ├── alembic/                      # DB migrations
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
│
└── CH3/                              # iOS app
    └── CH3/
        ├── CH3App.swift              # Entry point + device registration
        ├── ContentView.swift         # Root navigation + environment wiring
        ├── Networking/               # ★ NEW: HTTP layer
        │   ├── APIEnvironment.swift  #   Base URL config
        │   ├── APIError.swift        #   Typed error enum
        │   └── APIClient.swift       #   actor URLSession wrapper
        ├── Services/                 # ★ NEW: API service layer
        │   ├── DeviceIdentityService.swift  #   Keychain UUID
        │   ├── UserService.swift            #   /api/users/*
        │   ├── ChatService.swift            #   /api/chats/*
        │   ├── MessageService.swift         #   /api/chats/{id}/messages/*
        │   └── FormService.swift            #   /api/forms/*, /api/chats/{id}/suggestions
        ├── Models/
        │   ├── API/                  # ★ NEW: DTO models
        │   │   ├── UserDTO.swift
        │   │   ├── ChatDTO.swift
        │   │   ├── MessageDTO.swift
        │   │   ├── FormDTO.swift
        │   │   └── MessageMapping.swift
        │   ├── AppModels.swift       #   CategoryType, RecentChat, PhraseSuggestion
        │   ├── ContextFormModels.swift  # ContextFormType, ContextFormStep, ContextFormSession
        │   ├── ChatStore.swift       #   @Observable state (★ MODIFIED)
        │   ├── ChatMessageLayout.swift  # Message grouping logic
        │   └── AppRoute.swift        #   Navigation routes
        ├── Features/
        │   ├── Home/HomeView.swift
        │   ├── RecentChats/RecentChatsListView.swift  # ★ MODIFIED
        │   ├── ContextForm/
        │   │   ├── CategoryContextFormView.swift      # ★ MODIFIED
        │   │   └── TransportModePickerView.swift
        │   ├── Conversation/ConversationView.swift    # ★ MODIFIED
        │   └── Shared/AILearnedModalView.swift
        ├── Components/               # Reusable UI components
        ├── DesignSystem/             # Colors, typography, themes
        └── MockData/                 # Legacy mock data (kept for fallback)
```

---

## Data Flow

### 1. App Launch → Device Registration

```
App Launch
  │
  ├─ DeviceIdentityService.shared.deviceId
  │   ├─ Read from Keychain: "com.conversa.device-identity"
  │   └─ If not found: generate UUID(), write to Keychain
  │
  └─ CH3App.task { registerDevice() }
      └─ UserService.shared.register(deviceId:)
          └─ POST /api/users/register  { "device_id": "..." }
              ├─ 201 → newly created
              └─ 200 → already exists (idempotent)
```

### 2. Viewing Chat List

```
RecentChatsListView appears
  │
  ├─ .task { chatStore.loadChats(for: .hotel) }
  │   └─ ChatService.shared.listChats(category: "hotel")
  │       └─ GET /api/chats?category=hotel&is_active=true
  │           └─ [ChatListItem, ...]
  │               └─ map to [RecentChat] via RecentChat(from:)
  │
  └─ ChatStore publishes changes → UI updates
```

### 3. Creating a New Chat (Form Flow)

```
Home → Category tap
  └─ NavigationLink → RecentChatsListView
      └─ Compose button
          └─ Transport: TransportModePickerView → CategoryContextFormView
          └─ Others:   CategoryContextFormView directly
              │
              ├─ .task { loadFormDefinition() }
              │   └─ FormService.getFormDefinition(formType: "hotel")
              │       └─ GET /api/forms/hotel
              │           └─ FormDefinitionResponse { steps: [...] }
              │               └─ map to ContextFormDefinition
              │
              ├─ User fills each step, answers stored in [String]
              │
              └─ User taps "Done" → finishForm()
                  └─ createChatOnBackend()
                      ├─ Build context_answers: {"0": "Famous Hotel", "1": "Anna Smith", ...}
                      └─ chatStore.createChat(category, formType, title, subtitle, countryCode, answers)
                          └─ ChatService.createChat(...)
                              └─ POST /api/chats  { category, form_type, title, ... }
                                  └─ ChatResponse
                                      └─ map to RecentChat, insert into ChatStore
                                          └─ Show "AI learned" modal → navigate to ConversationView
```

### 4. Conversation (Send + Receive)

```
ConversationView appears
  │
  ├─ .task { loadMessageHistory() }
  │   └─ MessageService.getMessageHistory(chatId:)
  │       └─ GET /api/chats/{id}/messages?limit=50&offset=0
  │           └─ [MessageResponse, ...]
  │               └─ map to [ChatMessage] via ChatMessage(from:)
  │
  ├─ .task { loadSuggestions() }
  │   └─ FormService.getSuggestions(chatId:)
  │       └─ POST /api/chats/{id}/suggestions  (empty body)
  │           └─ SuggestionResponse { phrases: ["...", "..."] }
  │               └─ map to [PhraseSuggestion]
  │
  └─ User sends a message
      ├─ Optimistic: append ChatMessage.user(text) immediately
      └─ sendToBackend(userText:)
          └─ MessageService.sendMessage(chatId:, text:)
              └─ POST /api/chats/{id}/messages  { "text": "..." }
                  └─ SendMessageResponse { user_message, ai_message }
                      ├─ Append AI reply: ChatMessage(from: response.aiMessage)
                      └─ Refresh suggestions for new context
```

### 5. Full Request Lifecycle (under the hood)

```
View calls Service method (e.g., ChatService.listChats)
  │
  ▼
Service calls APIClient.shared.get("/api/chats?category=hotel")
  │
  ▼
APIClient (actor):
  1. Reads deviceId from DeviceIdentityService
  2. Builds URLRequest:
     - URL: "http://localhost:8000/api/chats?category=hotel"
     - Method: GET
     - Headers: Content-Type: application/json
                Accept: application/json
                X-Device-Id: <keychain-uuid>
  3. Calls URLSession.shared.data(for: request)
  4. Checks HTTP status:
     - 2xx → decode JSON with JSONDecoder (snake_case → camelCase)
     - 401 → throw APIError.unauthorized
     - 404 → throw APIError.notFound
     - 5xx → throw APIError.server(statusCode, body)
  5. Returns decoded DTO (e.g., [ChatListItem])
  │
  ▼
Service returns DTO to caller
  │
  ▼
View/ChatStore maps DTO → local model → UI updates
```

---

## API Reference

All endpoints are prefixed with `/api`. The iOS base URL is `http://localhost:8000` in development.

### Users

#### Register device
```
POST /api/users/register
Content-Type: application/json

Request:
{
  "device_id": "550e8400-e29b-41d4-a716-446655440000"
}

Response 201 (new) / 200 (existing):
{
  "id": "abc123...",
  "device_id": "550e8400-...",
  "display_name": null,
  "preferences": null,
  "created_at": "2026-06-02T10:30:00Z"
}
```

#### Get user profile
```
GET /api/users/{user_id}
X-Device-Id: 550e8400-...
```

#### Update user
```
PATCH /api/users/{user_id}
X-Device-Id: 550e8400-...

Request:
{
  "display_name": "Anna",
  "preferences": { "language": "en" }
}
```

### Chats

All chat endpoints require the `X-Device-Id` header (except where noted).

#### List chats
```
GET /api/chats?category=hotel&is_active=true
X-Device-Id: 550e8400-...

Response 200:
[
  {
    "id": "chat-uuid-1",
    "category": "hotel",
    "form_type": "hotel",
    "title": "Famous Hotel",
    "subtitle": "Kuta, Bali",
    "country_code": "ID",
    "is_active": true,
    "created_at": "2026-01-07T08:00:00Z",
    "updated_at": "2026-01-07T08:00:00Z"
  }
]
```

#### Create chat
```
POST /api/chats
X-Device-Id: 550e8400-...
Content-Type: application/json

Request:
{
  "category": "hotel",
  "form_type": "hotel",
  "title": "Famous Hotel",
  "subtitle": "Kuta, Bali",
  "country_code": "ID",
  "context_answers": {
    "0": "Famous Hotel",
    "1": "Anna Smith",
    "2": "Jan 10, 2026 – Jan 14, 2026",
    "3": "High floor, quiet room",
    "4": "No allergies",
    "5": "Check-in and checkout conversations",
    "6": ""
  }
}

Response 201:
{
  "id": "chat-uuid-new",
  "user_id": "user-uuid",
  "category": "hotel",
  "form_type": "hotel",
  "title": "Famous Hotel",
  "subtitle": "Kuta, Bali",
  "country_code": "ID",
  "context_answers": { ... },
  "is_active": true,
  "created_at": "2026-06-02T10:35:00Z",
  "updated_at": "2026-06-02T10:35:00Z",
  "chat_type_display": "Hotel"
}
```

#### Get single chat
```
GET /api/chats/{chat_id}
X-Device-Id: 550e8400-...
```

#### Delete (soft)
```
DELETE /api/chats/{chat_id}
X-Device-Id: 550e8400-...

Response 204 (no body)
```

### Messages

#### Get message history
```
GET /api/chats/{chat_id}/messages?limit=50&offset=0
X-Device-Id: 550e8400-...

Response 200:
[
  {
    "id": "msg-uuid-1",
    "chat_id": "chat-uuid",
    "sender": "user",
    "text": "Hi, I'm deaf. Can you speak to my phone please?",
    "is_transcribed": false,
    "created_at": "2026-06-02T10:35:00Z"
  },
  {
    "id": "msg-uuid-2",
    "chat_id": "chat-uuid",
    "sender": "ai",
    "text": "Of course! I'd be happy to help...",
    "is_transcribed": true,
    "created_at": "2026-06-02T10:35:02Z"
  }
]
```

#### Send message + get AI reply
```
POST /api/chats/{chat_id}/messages
X-Device-Id: 550e8400-...
Content-Type: application/json

Request:
{
  "text": "Please tell reception I cannot hear and prefer written instructions."
}

Response 201:
{
  "user_message": {
    "id": "msg-1",
    "chat_id": "chat-uuid",
    "sender": "user",
    "text": "Please tell reception I cannot hear...",
    "is_transcribed": false,
    "created_at": "2026-06-02T10:36:00Z"
  },
  "ai_message": {
    "id": "msg-2",
    "chat_id": "chat-uuid",
    "sender": "ai",
    "text": "Certainly! Here's what you can say: ...",
    "is_transcribed": false,
    "created_at": "2026-06-02T10:36:03Z"
  }
}
```

### Forms & Suggestions

#### Get form definition
```
GET /api/forms/hotel

Response 200:
{
  "form_type": "hotel",
  "title": "Hotel",
  "icon_system_name": "bed.double.fill",
  "steps": [
    {
      "index": 0,
      "prompt": "What hotel are you staying at?",
      "input_kind": "text",
      "placeholder": "Hotel name"
    },
    {
      "index": 1,
      "prompt": "What name is the booking under?",
      "input_kind": "text",
      "placeholder": "Booking name"
    },
    {
      "index": 2,
      "prompt": "What are your check-in and check-out dates?",
      "input_kind": "date_range",
      "placeholder": "Dates"
    }
    // ... remaining steps
  ]
}
```

Valid `form_type` values: `airport`, `cab`, `bus`, `hotel`, `store`, `misc_generic`

#### Get suggestions
```
POST /api/chats/{chat_id}/suggestions
X-Device-Id: 550e8400-...

Request: (empty JSON body or {})

Response 200:
{
  "phrases": [
    "Can I have a late checkout?",
    "Is breakfast included?",
    "Can you call a taxi for me?",
    "Where is the nearest pharmacy?"
  ]
}
```

---

## Authentication Model

The backend uses **device-based authentication** — no user accounts, passwords, or OAuth.

### How it works

1. **iOS generates a UUID** on first launch via `DeviceIdentityService`
2. UUID is stored in the **iOS Keychain** (survives app reinstalls within the same keychain group)
3. Every API request includes the header: `X-Device-Id: <uuid>`
4. The backend's `get_current_user` dependency looks up the user by `device_id`
5. If no user found → returns `404` with `"User not found for provided device id. Register first."`

### Keychain details

| Property | Value |
|---|---|
| Service | `com.conversa.device-identity` |
| Account | `conversa.deviceId` |
| Accessibility | `kSecAttrAccessibleAfterFirstUnlock` |
| Value | UUID string (e.g., `550e8400-e29b-41d4-a716-446655440000`) |

### Registration flow

```
1. CH3App.task { registerDevice() }
2. DeviceIdentityService.shared.deviceId → returns existing or generates new UUID
3. UserService.shared.register(deviceId:) → POST /api/users/register
4. Backend: INSERT ... ON CONFLICT (device_id) DO NOTHING
   - 201: newly created
   - 200: already existed (no-op)
5. All subsequent API calls include X-Device-Id automatically via APIClient
```

---

## iOS Networking Stack

### Layer diagram

```
┌──────────────────────────────────────┐
│  Views (SwiftUI)                     │
│  - RecentChatsListView               │
│  - CategoryContextFormView           │
│  - ConversationView                  │
└────────────┬─────────────────────────┘
             │ calls async methods
             ▼
┌──────────────────────────────────────┐
│  ChatStore (@Observable)             │
│  - loadChats(for:) → updates UI      │
│  - createChat(...) → returns model   │
│  - isLoading, errorMessage states    │
└────────────┬─────────────────────────┘
             │ delegates to services
             ▼
┌──────────────────────────────────────┐
│  Service Layer (stateless singletons) │
│  - UserService.shared                │
│  - ChatService.shared                │
│  - MessageService.shared             │
│  - FormService.shared                │
│                                      │
│  Each method:                        │
│    1. Validates params               │
│    2. Calls APIClient                │
│    3. Returns typed DTO              │
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│  APIClient (actor)                   │
│  - Thread-safe singleton             │
│  - Wraps URLSession.shared           │
│  - Auto-attaches X-Device-Id         │
│  - JSON encode/decode                │
│  - Status code → APIError mapping    │
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│  DeviceIdentityService               │
│  - Keychain read/write               │
│  - deviceId: String (computed)       │
└──────────────────────────────────────┘
```

### APIClient methods

```swift
actor APIClient {
    // GET with JSON response decoding
    func get<T: Decodable>(_ path: String) async throws -> T

    // POST with request body encoding + response decoding
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T

    // POST with empty body + response decoding
    func postEmptyBody<T: Decodable>(_ path: String) async throws -> T

    // DELETE (no response body)
    func delete(_ path: String) async throws
}
```

### JSON coding strategy

```swift
// Decoder (snake_case → camelCase)
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601

// Encoder (camelCase → snake_case)
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.dateEncodingStrategy = .iso8601
```

Example mapping:
```
Backend JSON:  { "device_id": "...", "created_at": "2026-06-02T..." }
Swift DTO:     { deviceId: "...", createdAt: Date }
```

---

## Model Mapping

### Backend → iOS DTO → Local Model

```
┌──────────────────────────────────────────────────────────────────┐
│ Backend (Python/Pydantic)                                        │
│                                                                  │
│ ChatListItem:                                                    │
│   id: UUID, category: "hotel", form_type: "hotel",               │
│   title: str, subtitle: str?, country_code: str,                 │
│   is_active: bool, created_at: datetime                          │
└──────────────────────────┬───────────────────────────────────────┘
                           │ JSON over HTTP
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│ iOS DTO (Codable)                                                │
│                                                                  │
│ struct ChatListItem: Decodable {                                 │
│   let id: String           // UUID string                        │
│   let category: String     // "hotel"                            │
│   let formType: String     // "hotel"                            │
│   let title: String                                              │
│   let subtitle: String?                                          │
│   let countryCode: String  // snake_case → camelCase auto        │
│   let isActive: Bool                                             │
│   let createdAt: Date      // ISO 8601 auto-decode               │
│ }                                                                │
└──────────────────────────┬───────────────────────────────────────┘
                           │ mapper extension
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│ iOS Local Model (SwiftUI)                                        │
│                                                                  │
│ struct RecentChat: Identifiable, Hashable {                      │
│   let id: UUID              // UUID(uuidString: dto.id)          │
│   let category: CategoryType // enum from dto.category string    │
│   let title: String                                              │
│   let subtitle: String      // nil → "" fallback                 │
│   let dateText: String      // formatted from dto.createdAt      │
│   let countryCode: String                                        │
│   let isNewConversation: Bool                                    │
│ }                                                                │
└──────────────────────────────────────────────────────────────────┘
```

### Enum mappings

| Backend string | iOS `CategoryType` | iOS `ContextFormType` |
|---|---|---|
| `"transport"` | `.transport` | — |
| `"store"` | `.store` | — |
| `"hotel"` | `.hotel` | — |
| `"misc"` | `.misc` | — |
| `"airport"` | — | `.airport` |
| `"cab"` | — | `.cab` |
| `"bus"` | — | `.bus` |
| `"hotel"` | — | `.hotel` |
| `"store"` | — | `.store` |
| `"misc_generic"` | — | `.miscGeneric` |

### Input kind mapping

| Backend `input_kind` | iOS `ContextInputKind` | UI Component |
|---|---|---|
| `"text"` | `.text` | `FormGlassTextField` |
| `"yes_no"` | `.yesNo` | `FormGlassYesNoPicker` |
| `"date_range"` | `.dateRange` | `FormGlassDateRangeField` |

### Message sender mapping

| Backend `sender` | iOS `MessageSender` | Bubble alignment |
|---|---|---|
| `"user"` | `.user` | Right (trailing) |
| `"ai"` | `.other` | Left (leading) |
| `"system"` | `.system` | Center |

---

## Error Handling

### Error types

```swift
enum APIError: LocalizedError {
    case network(URLError)           // No internet, timeout, DNS failure
    case server(Int, String?)        // 5xx or unexpected status code
    case unauthorized                 // 401 — device not registered
    case notFound                     // 404 — resource doesn't exist
    case decoding(Error)              // JSON parsing failure
    case unknown(Error)               // Catch-all
}
```

### How each view handles errors

| View | Error type | User sees |
|---|---|---|
| `RecentChatsListView` | Network / server | WiFi-slash icon + message + Retry button |
| `CategoryContextFormView` | Form load failure | Error banner on themed background + Retry |
| `CategoryContextFormView` | Chat creation failure | Red error text above Done button |
| `ConversationView` | History load failure | Error state with Retry button |
| `ConversationView` | Message send failure | Red error text above input bar (message stays in chat) |

### Error recovery strategy

```
┌──────────────┐
│  Error occurs │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────┐
│  Is existing data still valid?   │
│  (cached chat list, old messages)│
└────┬──────────────────┬──────────┘
     │ Yes              │ No
     ▼                  ▼
  Keep cached      Show error state
  data visible     with Retry button
  + inline error
```

---

## State Management

### ChatStore (`@Observable`)

The central state object, injected via `.environment(chatStore)` in `ContentView`.

```swift
@Observable
final class ChatStore {
    var chatsByCategory: [CategoryType: [RecentChat]]  // Data
    var isLoading: Bool                                 // UI state
    var errorMessage: String?                           // UI state

    // Backend operations
    func loadChats(for category: CategoryType) async
    func loadAllChats() async
    func createChat(...) async throws -> RecentChat
    func deleteChat(_ chat: RecentChat) async

    // Local mutation
    func add(_ chat: RecentChat)
}
```

### View-level state (not in ChatStore)

Each view manages its own transient UI state:

| View | Local @State properties |
|---|---|
| `RecentChatsListView` | `searchText` (search bar) |
| `CategoryContextFormView` | `stepIndex`, `answers[]`, `currentAnswer`, `checkInDate`, `checkOutDate`, `isCreating`, `createError`, `showAIModal`, `pendingChat` |
| `ConversationView` | `messages[]`, `inputText`, `isSending`, `sendError`, `suggestions[]`, `isLoadingHistory`, `historyError`, `micIsActive` |

### Why separate services vs. putting everything in ChatStore?

| In ChatStore | In Services |
|---|---|
| State that drives UI updates | Stateless network calls |
| Shared across multiple views | Called by ChatStore or views directly |
| `@Observable` triggers SwiftUI re-renders | Simple async/await, no observation needed |
| Chat list, loading flags | HTTP methods, DTO mapping |

---

## Setup & Running

### Prerequisites

- **Backend**: Docker + Docker Compose, or Python 3.12+ with PostgreSQL 17
- **iOS**: Xcode 26+ (project targets iOS 26.0), macOS 15+

### Step 1: Start the backend

```bash
cd backend

# Set your LLM credentials
export LLM_API_KEY=sk-your-key-here
export LLM_MODEL=gpt-4o-mini
# Optional: use OpenRouter or another provider
# export LLM_BASE_URL=https://openrouter.ai/api/v1

# Start services (API + PostgreSQL)
docker compose up -d

# Apply database migrations
docker compose exec api alembic upgrade head

# Optional: seed sample data
docker compose exec api python -m app.seed

# Verify it's running
curl http://localhost:8000/health
# → {"status": "ok"}
```

### Step 2: Add new files to Xcode project

1. Open `CH3/CH3.xcodeproj` in Xcode
2. Right-click the `CH3` group → **Add Files to "CH3"…**
3. Navigate to and select:
   - `CH3/CH3/Networking/` (the entire folder)
   - `CH3/CH3/Services/` (the entire folder)
   - `CH3/CH3/Models/API/` (the entire folder)
4. Ensure **"Create groups"** is selected
5. Ensure the **CH3 target** is checked
6. Click **Add**

### Step 3: Configure networking for simulator

The iOS simulator can reach `localhost:8000` directly (simulator shares the Mac's network).

If using a physical device, update `APIEnvironment.swift`:

```swift
static let baseURL = "http://<your-mac-ip>:8000"
```

### Step 4: Run the app

1. Select the **CH3** scheme
2. Choose an **iOS Simulator** (iPhone 16 or later recommended)
3. Press **Run** (⌘R)

### What happens on first launch

1. App generates a UUID → stores in Keychain
2. `POST /api/users/register` → device registered
3. Home screen shows category cards
4. Tap a category → chat list loads from backend (empty on first use)
5. Tap compose → form loads from backend → fill → creates chat → navigate to conversation
6. Type a message → sends to backend → AI reply appears

---

## Troubleshooting

### "User not found for provided device id"

**Cause**: Device hasn't been registered yet, or registration failed silently.

**Fix**:
1. Check that the backend is running: `curl http://localhost:8000/health`
2. In Xcode console, look for `[CH3App] Device registration failed: ...`
3. Force registration by deleting the app from the simulator and re-running (Keychain resets)
4. Verify Keychain item exists: check `DeviceIdentityService.shared.deviceId` in a breakpoint

### "Network error: A server with the specified hostname could not be found"

**Cause**: iOS simulator can't reach `localhost:8000`.

**Fix**:
1. Verify backend is running: `docker compose ps` (both `api` and `db` should be Up)
2. If using physical device, update `APIEnvironment.baseURL` to your Mac's IP
3. Check `docker compose logs api` for backend startup errors
4. Ensure no firewall is blocking port 8000

### "Server error (code 500)"

**Cause**: Backend crashed or LLM API call failed.

**Fix**:
1. Check backend logs: `docker compose logs api`
2. Verify LLM_API_KEY is set and valid
3. Verify LLM_MODEL is correct for your provider
4. If using OpenRouter, ensure LLM_BASE_URL is set

### Messages send but no AI reply appears

**Cause**: The `SendMessageResponse` parsing failed, or the AI service threw an error.

**Fix**:
1. Check Xcode console for decoding errors
2. Verify the backend schema matches `MessageDTO.swift`
3. Check backend logs: `docker compose logs api | grep -i error`

### Form loads forever (spinner never stops)

**Cause**: The form type string doesn't match what the backend expects.

**Fix**:
1. Verify `ContextFormType.apiValue` matches backend `FormType` enum values
2. Check mapping: `airport`, `cab`, `bus`, `hotel`, `store`, `misc_generic`
3. Check backend: `curl http://localhost:8000/api/forms/hotel`

### Pull-to-refresh doesn't load new chats

**Cause**: The chat wasn't created successfully, or `createChat` didn't update `ChatStore`.

**Fix**:
1. After form completion, check that the "AI learned" modal appeared
2. Verify the chat appears in `curl http://localhost:8000/api/chats -H "X-Device-Id: <your-uuid>"`
3. Check Xcode console for any errors during `createChatOnBackend()`

### Switching between mock data and live backend

The app currently falls back to mock data in `ChatStore.init()`:

```swift
init() {
    chatsByCategory = AppMockData.recentChatsByCategory
}
```

The mock data is overridden once `loadChats(for:)` succeeds. If you want to disable mock data entirely, replace the init with:

```swift
init() {
    chatsByCategory = [:]
}
```

---

## Appendix: Quick curl test sequence

Use this to verify the backend independently of the iOS app:

```bash
# 1. Health check
curl http://localhost:8000/health

# 2. Register device
DEVICE_ID="test-device-$(uuidgen)"
curl -X POST http://localhost:8000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"device_id\": \"$DEVICE_ID\"}"

# 3. Get form definition
curl http://localhost:8000/api/forms/hotel

# 4. Create a chat
CHAT=$(curl -s -X POST http://localhost:8000/api/chats \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: $DEVICE_ID" \
  -d '{
    "category": "hotel",
    "form_type": "hotel",
    "title": "Test Hotel",
    "subtitle": "Test Location",
    "country_code": "ID",
    "context_answers": {
      "0": "Test Hotel",
      "1": "Anna Smith",
      "2": "Jan 10-14, 2026",
      "3": "Quiet room",
      "4": "None",
      "5": "Check-in help",
      "6": ""
    }
  }')
CHAT_ID=$(echo $CHAT | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "Created chat: $CHAT_ID"

# 5. List chats
curl -s http://localhost:8000/api/chats \
  -H "X-Device-Id: $DEVICE_ID" | python3 -m json.tool

# 6. Send a message
curl -s -X POST "http://localhost:8000/api/chats/$CHAT_ID/messages" \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: $DEVICE_ID" \
  -d '{"text": "Hello, I need help checking in."}' | python3 -m json.tool

# 7. Get suggestions
curl -s -X POST "http://localhost:8000/api/chats/$CHAT_ID/suggestions" \
  -H "X-Device-Id: $DEVICE_ID" | python3 -m json.tool
```
