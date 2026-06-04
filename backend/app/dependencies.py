import uuid
from typing import Annotated

from app.database import get_db
from app.models import Chat, User
from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

DeviceIdHeader = Annotated[str, Header(..., alias="X-Device-Id")]


async def get_current_user(
    device_id: DeviceIdHeader,
    db: AsyncSession = Depends(get_db),
) -> User:
    """Resolve an existing user from device header."""
    result = await db.execute(
        select(User).where(User.device_id == device_id)
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found for provided device id. Register first.",
        )

    return user


async def get_or_create_user(
    device_id: str,
    db: AsyncSession,
) -> User:
    result = await db.execute(select(User).where(User.device_id == device_id))
    user = result.scalar_one_or_none()
    if user is None:
        user = User(device_id=device_id)
        db.add(user)
        await db.commit()
        await db.refresh(user)
    return user


async def get_owned_chat(
    chat_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Chat:
    result = await db.execute(
        select(Chat).where(Chat.id == chat_id, Chat.user_id == user.id)
    )
    chat = result.scalar_one_or_none()
    if chat is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")
    return chat
