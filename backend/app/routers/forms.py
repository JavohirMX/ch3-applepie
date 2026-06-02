import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_owned_chat
from app.models import Chat, Message
from app.models.chat import FormType
from app.schemas.form import FormDefinitionResponse, FormStepResponse, SuggestionResponse
from app.services import get_form_definition, generate_suggestions

router = APIRouter(prefix="/api", tags=["forms"])


@router.get("/forms/{form_type}", response_model=FormDefinitionResponse)
async def get_form(form_type: FormType):
    """Get the form definition (steps) for a given form type."""
    definition = get_form_definition(form_type)
    if not definition:
        raise HTTPException(status_code=404, detail=f"Form type '{form_type.value}' not found")

    steps = [
        FormStepResponse(
            index=i,
            prompt=step["prompt"],
            input_kind=step["input_kind"],
            placeholder=step["placeholder"],
        )
        for i, step in enumerate(definition["steps"])
    ]

    return FormDefinitionResponse(
        form_type=form_type.value,
        title=definition["title"],
        icon_system_name=definition["icon_system_name"],
        steps=steps,
    )


@router.post("/chats/{chat_id}/suggestions", response_model=SuggestionResponse)
async def get_suggestions(
    chat_id: uuid.UUID,
    chat: Chat = Depends(get_owned_chat),
    db: AsyncSession = Depends(get_db),
):
    """Generate quick-reply phrase suggestions for a chat."""
    # Get recent messages
    msg_result = await db.execute(
        select(Message)
        .where(Message.chat_id == chat_id)
        .order_by(Message.created_at.desc())
        .limit(10)
    )
    messages = msg_result.scalars().all()
    history = [
        {"sender": m.sender.value, "text": m.text}
        for m in reversed(messages)
    ]

    phrases = await generate_suggestions(
        context_answers=chat.context_answers,
        chat_history=history,
        form_type=chat.form_type.value,
    )

    return SuggestionResponse(phrases=phrases)
