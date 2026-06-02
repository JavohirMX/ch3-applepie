from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_owned_chat
from app.models import Chat
from app.schemas.message import MessageCreateRequest, MessageResponse, SendMessageResponse
from app.services import list_chat_messages, send_message_and_generate_reply

router = APIRouter(prefix="/api/chats/{chat_id}/messages", tags=["messages"])


@router.get("", response_model=list[MessageResponse])
async def list_messages(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    chat: Chat = Depends(get_owned_chat),
    db: AsyncSession = Depends(get_db),
):
    """List messages for a chat, paginated."""
    return await list_chat_messages(db=db, chat_id=chat.id, limit=limit, offset=offset)


@router.post("", response_model=SendMessageResponse, status_code=201)
async def send_message(
    body: MessageCreateRequest,
    chat: Chat = Depends(get_owned_chat),
    db: AsyncSession = Depends(get_db),
):
    """Send a user message and get an AI-generated reply."""
    return await send_message_and_generate_reply(
        db=db,
        chat_id=chat.id,
        form_type=chat.form_type.value,
        context_answers=chat.context_answers,
        body=body,
    )
