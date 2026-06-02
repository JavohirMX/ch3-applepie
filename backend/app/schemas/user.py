import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class UserRegisterRequest(BaseModel):
    device_id: str = Field(min_length=3, max_length=255)


class UserResponse(BaseModel):
    id: uuid.UUID
    device_id: str
    display_name: str | None
    preferences: dict[str, Any] | None
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdateRequest(BaseModel):
    display_name: str | None = Field(default=None, min_length=1, max_length=255)
    preferences: dict[str, Any] | None = None
