import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Message, MessageSender
from app.schemas.message import MessageCreateRequest, SendMessageResponse
from app.services.openai_service import generate_ai_reply


async def list_chat_messages(
    db: AsyncSession,
    chat_id: uuid.UUID,
    limit: int,
    offset: int,
) -> list[Message]:
    query = (
        select(Message)
        .where(Message.chat_id == chat_id)
        .order_by(Message.created_at.asc())
        .offset(offset)
        .limit(limit)
    )
    result = await db.execute(query)
    return result.scalars().all()


async def send_message_and_generate_reply(
    db: AsyncSession,
    chat_id: uuid.UUID,
    form_type: str,
    context_answers: dict | None,
    body: MessageCreateRequest,
) -> SendMessageResponse:
    user_msg = Message(chat_id=chat_id, sender=MessageSender.user, text=body.text)
    db.add(user_msg)
    await db.flush()

    history_result = await db.execute(
        select(Message).where(Message.chat_id == chat_id).order_by(Message.created_at.asc())
    )
    all_messages = history_result.scalars().all()
    history = [{"sender": m.sender.value, "text": m.text} for m in all_messages]

    ai_text = await generate_ai_reply(
        user_message=body.text,
        context_answers=context_answers,
        chat_history=history,
        form_type=form_type,
    )

    ai_msg = Message(chat_id=chat_id, sender=MessageSender.ai, text=ai_text)
    db.add(ai_msg)
    await db.commit()
    await db.refresh(user_msg)
    await db.refresh(ai_msg)

    return SendMessageResponse(user_message=user_msg, ai_message=ai_msg)
