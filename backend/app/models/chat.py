import enum
import uuid
from datetime import datetime

from sqlalchemy import String, DateTime, Enum, Boolean, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class CategoryType(str, enum.Enum):
    transport = "transport"
    store = "store"
    hotel = "hotel"
    misc = "misc"


class FormType(str, enum.Enum):
    airport = "airport"
    cab = "cab"
    bus = "bus"
    hotel = "hotel"
    store = "store"
    misc_generic = "misc_generic"


class Chat(Base):
    __tablename__ = "chats"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    category: Mapped[CategoryType] = mapped_column(Enum(CategoryType, name="category_type"), nullable=False)
    form_type: Mapped[FormType] = mapped_column(Enum(FormType, name="form_type"), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    subtitle: Mapped[str | None] = mapped_column(String(255))
    country_code: Mapped[str] = mapped_column(String(3), default="ID")
    context_answers: Mapped[dict | None] = mapped_column(JSONB, comment="Array of form answers keyed by index: {'0':'...','1':'...','2':...}")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="chats")
    messages: Mapped[list["Message"]] = relationship(
        back_populates="chat",
        lazy="selectin",
        order_by="Message.created_at",
        cascade="all, delete-orphan",
    )

    @property
    def chat_type_display(self) -> str:
        """Returns 'Hotel Stay', 'Cab Ride', 'Store Visit', etc. for the form type."""
        labels = {
            FormType.airport: "Airport Trip",
            FormType.cab: "Cab Ride",
            FormType.bus: "Bus Trip",
            FormType.hotel: "Hotel Stay",
            FormType.store: "Store Visit",
            FormType.misc_generic: "New Chat",
        }
        return labels.get(self.form_type, "New Chat")
