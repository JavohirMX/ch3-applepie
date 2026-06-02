import enum
import uuid
from datetime import datetime

from sqlalchemy import String, DateTime, Enum, Boolean, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class MessageSender(str, enum.Enum):
    user = "user"
    ai = "ai"
    system = "system"


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    chat_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("chats.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    sender: Mapped[MessageSender] = mapped_column(
        Enum(MessageSender, name="message_sender"), nullable=False
    )
    text: Mapped[str] = mapped_column(String(4000), nullable=False)
    is_transcribed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    chat: Mapped["Chat"] = relationship(back_populates="messages")
