import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.message import MessageSender


class MessageCreateRequest(BaseModel):
    text: str = Field(min_length=1, max_length=4000)


class MessageResponse(BaseModel):
    id: uuid.UUID
    chat_id: uuid.UUID
    sender: MessageSender
    text: str
    is_transcribed: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class SendMessageResponse(BaseModel):
    user_message: MessageResponse
    ai_message: MessageResponse
