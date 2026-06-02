import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.models.chat import CategoryType, FormType


class ChatCreateRequest(BaseModel):
    category: CategoryType
    form_type: FormType
    title: str = Field(min_length=1, max_length=255)
    subtitle: str | None = Field(default=None, max_length=255)
    country_code: str = Field(default="ID", pattern=r"^[A-Z]{2,3}$")
    context_answers: dict[str, Any] | None = None


class ChatResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    category: CategoryType
    form_type: FormType
    title: str
    subtitle: str | None
    country_code: str
    context_answers: dict[str, Any] | None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    chat_type_display: str

    model_config = {"from_attributes": True}


class ChatListItem(BaseModel):
    id: uuid.UUID
    category: CategoryType
    form_type: FormType
    title: str
    subtitle: str | None
    country_code: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
