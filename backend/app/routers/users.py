import uuid

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_or_create_user
from app.models import User
from app.schemas.user import UserRegisterRequest, UserResponse, UserUpdateRequest

router = APIRouter(prefix="/api/users", tags=["users"])


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    responses={200: {"description": "User already exists"}},
)
async def register_user(
    body: UserRegisterRequest,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    """Register or retrieve a user by device_id."""
    result = await db.execute(select(User).where(User.device_id == body.device_id))
    existing_user = result.scalar_one_or_none()
    if existing_user is not None:
        response.status_code = status.HTTP_200_OK
        return existing_user
    user = await get_or_create_user(body.device_id, db)
    return user


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get a user by ID."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: uuid.UUID,
    body: UserUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Update a user's display name or preferences."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if body.display_name is not None:
        user.display_name = body.display_name
    if body.preferences is not None:
        user.preferences = body.preferences

    await db.commit()
    await db.refresh(user)
    return user
