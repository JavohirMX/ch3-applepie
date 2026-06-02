from openai import APIError, AsyncOpenAI

from app.config import settings
from app.models.chat import FormType
from app.services.form_definitions import humanize_context

client = AsyncOpenAI(
    api_key=settings.llm_api_key,
    base_url=settings.llm_base_url,
)

SYSTEM_PROMPT = """You are a helpful, concise communication assistant for a deaf or hard-of-hearing traveler. 
The user communicates by typing messages which you help convey to another person (e.g., a hotel clerk, 
taxi driver, store employee, airport staff).

Context about the user's situation will be provided. Use it to tailor your responses.

Rules:
- Be concise and practical — 1-3 sentences unless the situation requires more detail.
- Write as if you ARE the user speaking to the other person, unless the user is asking YOU a direct question.
- If the user types a message meant for the other person, reply with a natural-sounding spoken version 
  that the other person would understand.
- If the user asks you a direct question (e.g., "how do I say...", "what does ... mean"), answer helpfully.
- Never mention being an AI or assistant in your reply to the other person.
- Adapt to the context: formal for hotels, casual for stores, practical for transport."""


async def generate_ai_reply(
    user_message: str,
    context_answers: dict | None,
    chat_history: list[dict],
    form_type: str,
) -> str:
    """Generate an AI reply given the conversation context."""
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    # Inject context form answers as a system message, with prompt-based keys
    readable_context = humanize_context(FormType(form_type), context_answers)
    if readable_context:
        context_text = "User's situation:\n" + "\n".join(
            f"- {k}: {v}" for k, v in readable_context.items()
        )
        messages.append({"role": "system", "content": context_text})

    messages.append({
        "role": "system",
        "content": f"This conversation is in the category: {form_type}. "
                   f"Adapt your tone and content accordingly.",
    })

    # Add recent chat history (last 20 messages)
    for msg in chat_history[-20:]:
        role = "assistant" if msg["sender"] == "ai" else "user"
        messages.append({"role": role, "content": msg["text"]})

    # Add the current user message
    messages.append({"role": "user", "content": user_message})

    try:
        response = await client.chat.completions.create(
            model=settings.llm_model,
            messages=messages,
            max_tokens=settings.llm_reply_max_tokens,
            temperature=settings.llm_reply_temperature,
        )
    except APIError as exc:
        raise RuntimeError(
            "LLM request failed. Check llm_api_key, llm_base_url, and llm_model configuration."
        ) from exc

    return response.choices[0].message.content or "I'm not sure how to help with that."


async def generate_suggestions(
    context_answers: dict | None,
    chat_history: list[dict],
    form_type: str,
    count: int = 4,
) -> list[str]:
    """Generate quick-reply phrase suggestions based on conversation context."""
    messages = [
        {
            "role": "system",
            "content": (
                "You are helping a deaf or hard-of-hearing traveler by suggesting short, "
                "practical phrases they might want to say next in their conversation. "
                "Return ONLY a JSON array of strings, no other text. "
                f"Generate exactly {count} suggestions."
            ),
        }
    ]

    readable_context = humanize_context(FormType(form_type), context_answers)
    if readable_context:
        context_text = "User's situation:\n" + "\n".join(
            f"- {k}: {v}" for k, v in readable_context.items()
        )
        messages.append({"role": "system", "content": context_text})

    messages.append({
        "role": "system",
        "content": f"Category: {form_type}. Suggest phrases that are natural in this context.",
    })

    if chat_history:
        history_text = "Recent conversation:\n" + "\n".join(
            f"{'User' if m['sender'] == 'user' else 'Other'}: {m['text']}"
            for m in chat_history[-6:]
        )
        messages.append({"role": "user", "content": history_text})

    messages.append({
        "role": "user",
        "content": "Based on the conversation above, what are the most useful next phrases the user could say?",
    })

    try:
        response = await client.chat.completions.create(
            model=settings.llm_model,
            messages=messages,
            max_tokens=settings.llm_suggestions_max_tokens,
            temperature=settings.llm_suggestions_temperature,
        )
    except APIError as exc:
        raise RuntimeError(
            "LLM request failed. Check llm_api_key, llm_base_url, and llm_model configuration."
        ) from exc

    import json
    content = response.choices[0].message.content or "{}"
    try:
        data = json.loads(content)
        if isinstance(data, list):
            return [str(item) for item in data[:count] if isinstance(item, str)]
        # Handle fallback object shape in case model doesn't follow instruction exactly.
        for key in ("phrases", "suggestions", "responses"):
            if key in data and isinstance(data[key], list):
                return [str(item) for item in data[key][:count] if isinstance(item, str)]
        return []
    except (json.JSONDecodeError, IndexError):
        return []
