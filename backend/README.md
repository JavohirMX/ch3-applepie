# Conversa Backend

Conversa backend is a FastAPI service for an iOS communication companion focused on deaf and hard-of-hearing travelers.
It stores user chats, applies context from travel forms, and generates AI-assisted responses and quick suggestions.

## Why this backend exists

When users are navigating hotels, airports, rides, and stores, they need fast, practical phrasing in context.
This API provides:

- persistent conversation history per device user
- context-aware AI responses (form answers are injected into prompts)
- category-specific quick suggestions for next phrases
- clean integration surface for iOS (`/api/*`, JSON-first, OpenAPI docs)

## Feature highlights

- **Device-based user identity** via `X-Device-Id` header
- **Chat organization** by category (`transport`, `store`, `hotel`, `misc`) and form type (`airport`, `cab`, `bus`, `hotel`, `store`, `misc_generic`)
- **Message flow** that saves user message + AI reply in one request
- **Suggestions endpoint** for short follow-up phrases
- **Soft delete chats** (`is_active=false`) instead of hard delete
- **Async stack** with FastAPI, SQLAlchemy async, Postgres, and Alembic migrations
- **Provider-agnostic LLM config** (OpenAI-compatible clients via model/base URL)

## Architecture at a glance

1. iOS sends request with `X-Device-Id`.
2. Dependencies resolve current user and ownership checks.
3. Routers validate I/O schemas and call service layer.
4. Services execute business logic + DB operations.
5. OpenAI-compatible client generates reply/suggestions.
6. API returns normalized response models.

Core modules:

- `app/main.py` - app setup, CORS config, router mounting, health check
- `app/dependencies.py` - auth and chat ownership guards
- `app/routers/` - route handlers
- `app/services/` - business logic (chat/message/form/LLM)
- `app/models/` - SQLAlchemy entities and enums
- `alembic/` - schema migrations

## Tech stack

- FastAPI
- SQLAlchemy (async) + asyncpg
- PostgreSQL 17
- Alembic
- Pydantic v2 / pydantic-settings
- OpenAI Python SDK (used as OpenAI-compatible client)

## Environment variables

From `.env.example`:

```env
LLM_API_KEY=your-provider-api-key
LLM_MODEL=gpt-4o-mini
# LLM_BASE_URL=https://openrouter.ai/api/v1
DATABASE_URL=postgresql+asyncpg://conversa:conversa@db:5432/conversa
APP_ENV=development
DEBUG=true
```

Notes:

- `LLM_BASE_URL` is optional. Leave unset for native OpenAI endpoint.
- `DATABASE_URL` should use `@db` when running in Docker Compose.
- For local (non-Docker) DB, use `@localhost` instead.

## Quick start (Docker)

```bash
# 1) set runtime vars in shell
export LLM_API_KEY=sk-...
export LLM_MODEL=gpt-4o-mini
# Optional:
# export LLM_BASE_URL=https://openrouter.ai/api/v1

# 2) start services
docker compose up -d

# 3) apply migrations
docker compose exec api alembic upgrade head

# 4) seed sample data (optional)
docker compose exec api python -m app.seed
```

Service URLs:

- API: `http://localhost:8000`
- OpenAPI docs: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/health`

## Quick start (Local development)

```bash
# 1) create env + install
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2) create local env file
cp .env.example .env

# 3) IMPORTANT: set local DB host
# DATABASE_URL=postgresql+asyncpg://conversa:conversa@localhost:5432/conversa

# 4) migrate and run
alembic upgrade head
uvicorn app.main:app --reload
```

## Authentication model

Protected endpoints use:

- `X-Device-Id: <device-id-string>`

Flow:

1. Register device with `POST /api/users/register`.
2. Reuse the same `X-Device-Id` in requests to chats/messages/suggestions.
3. Backend resolves the user and enforces chat ownership.

If device is unknown, protected endpoints return `404` with:
`User not found for provided device id. Register first.`

## API reference (practical)

### Users

- `POST /api/users/register` - create or return user by `device_id`
  - returns `201` when created, `200` when already exists
- `GET /api/users/{user_id}` - fetch profile
- `PATCH /api/users/{user_id}` - update `display_name` / `preferences`

### Chats

- `GET /api/chats?category=<optional>&is_active=true` - list user's chats
- `POST /api/chats` - create a chat from form context
- `GET /api/chats/{chat_id}` - get one owned chat
- `DELETE /api/chats/{chat_id}` - soft delete (`204`)

### Messages

- `GET /api/chats/{chat_id}/messages?limit=50&offset=0` - paginated ascending history
- `POST /api/chats/{chat_id}/messages` - save user message and AI reply

### Forms & Suggestions

- `GET /api/forms/{form_type}` - return step definitions for context forms
- `POST /api/chats/{chat_id}/suggestions` - generate quick phrases from recent context

## End-to-end example flow (curl)

### 1) Register user

```bash
curl -X POST http://localhost:8000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "ios-sim-001"
  }'
```

### 2) Create chat

```bash
curl -X POST http://localhost:8000/api/chats \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: ios-sim-001" \
  -d '{
    "category": "hotel",
    "form_type": "hotel",
    "title": "Famous Hotel",
    "subtitle": "Kuta, Bali",
    "country_code": "ID",
    "context_answers": {
      "0": "Famous Hotel",
      "1": "Anna Smith",
      "2": "Jan 10, 2026 - Jan 14, 2026",
      "3": "High floor, quiet room",
      "4": "No allergies",
      "5": "Check-in and checkout conversations",
      "6": ""
    }
  }'
```

### 3) Send message and get AI reply

```bash
curl -X POST http://localhost:8000/api/chats/<chat_id>/messages \
  -H "Content-Type: application/json" \
  -H "X-Device-Id: ios-sim-001" \
  -d '{
    "text": "Please tell reception I cannot hear and prefer written instructions."
  }'
```

### 4) Request quick suggestions

```bash
curl -X POST http://localhost:8000/api/chats/<chat_id>/suggestions \
  -H "X-Device-Id: ios-sim-001"
```

## Data model overview

### User

- `id`, `device_id` (unique), `display_name`, `preferences`, timestamps

### Chat

- owned by user
- `category`, `form_type`, `title`, `subtitle`, `country_code`
- `context_answers` stored as JSON by step index keys (`"0"`, `"1"`, ...)
- `is_active` for soft deletion

### Message

- belongs to chat
- `sender` enum: `user`, `ai`, `system`
- `text`, `is_transcribed`, `created_at`

## Project structure

```text
backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── dependencies.py
│   ├── seed.py
│   ├── models/
│   ├── schemas/
│   ├── routers/
│   └── services/
│       ├── openai_service.py
│       ├── form_definitions.py
│       ├── chat_service.py
│       └── message_service.py
├── alembic/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── .env.example
```

## Troubleshooting

### Startup fails with validation errors

- Check required env vars: `LLM_API_KEY`, `LLM_MODEL`, `DATABASE_URL`.
- Empty `LLM_API_KEY` or `LLM_MODEL` fails settings validation at startup.

### LLM requests fail at runtime

- Verify key/model pair is valid for your provider.
- If using non-default provider, set correct `LLM_BASE_URL`.
- Backend raises runtime error if provider call fails.

### `404 User not found for provided device id`

- Register first using `POST /api/users/register`.
- Ensure the exact same `X-Device-Id` is reused.

### Database connection issues

- Docker mode: use host `db`.
- Local mode: use host `localhost`.
- Confirm Postgres is running and credentials match `DATABASE_URL`.

### CORS behavior confusion

- In `APP_ENV=development`, CORS is permissive (`*`).
- In non-dev env, allowed origins come from `cors_origins` settings.

## Contribution notes

- Keep endpoint behavior documented whenever routes/services change.
- Add Alembic migration for schema updates.
- Prefer service-layer logic for non-trivial router behavior.

---

If you are integrating the iOS app, start with the end-to-end flow above and keep a stable `X-Device-Id` per device install for consistent user mapping.
