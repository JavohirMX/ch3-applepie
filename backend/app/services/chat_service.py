from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import CategoryType, Chat, User
from app.schemas.chat import ChatCreateRequest


async def list_user_chats(
    db: AsyncSession,
    user: User,
    category: CategoryType | None,
    is_active: bool,
) -> list[Chat]:
    query = select(Chat).where(Chat.user_id == user.id, Chat.is_active == is_active)
    if category:
        query = query.where(Chat.category == category)
    query = query.order_by(Chat.updated_at.desc())
    result = await db.execute(query)
    return result.scalars().all()


async def create_chat_for_user(
    db: AsyncSession,
    user: User,
    body: ChatCreateRequest,
) -> Chat:
    chat = Chat(
        user_id=user.id,
        category=body.category,
        form_type=body.form_type,
        title=body.title,
        subtitle=body.subtitle,
        country_code=body.country_code,
        context_answers=body.context_answers,
    )
    db.add(chat)
    await db.commit()
    await db.refresh(chat)
    return chat


async def soft_delete_chat(db: AsyncSession, chat: Chat) -> None:
    chat.is_active = False
    await db.commit()
