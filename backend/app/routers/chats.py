from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, get_owned_chat
from app.models import CategoryType, Chat, User
from app.schemas.chat import ChatCreateRequest, ChatResponse, ChatListItem
from app.services import create_chat_for_user, list_user_chats, soft_delete_chat

router = APIRouter(prefix="/api/chats", tags=["chats"])


@router.get("", response_model=list[ChatListItem])
async def list_chats(
    category: CategoryType | None = Query(None),
    is_active: bool = Query(True),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List chats for a user, optionally filtered by category."""
    return await list_user_chats(db=db, user=user, category=category, is_active=is_active)


@router.post("", response_model=ChatResponse, status_code=201)
async def create_chat(
    body: ChatCreateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new chat (called after completing the context form)."""
    return await create_chat_for_user(db=db, user=user, body=body)


@router.get("/{chat_id}", response_model=ChatResponse)
async def get_chat(
    chat: Chat = Depends(get_owned_chat),
):
    """Get a single chat by ID."""
    return chat


@router.delete("/{chat_id}", status_code=204)
async def delete_chat(
    chat: Chat = Depends(get_owned_chat),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete a chat (sets is_active=False)."""
    await soft_delete_chat(db=db, chat=chat)
