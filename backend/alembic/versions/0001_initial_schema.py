"""initial_schema

Revision ID: 0001
Revises:
Create Date: 2026-06-02
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("device_id", sa.String(255), nullable=False),
        sa.Column("display_name", sa.String(255), nullable=True),
        sa.Column("preferences", postgresql.JSONB, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_users")),
        sa.UniqueConstraint("device_id", name=op.f("uq_users_device_id")),
    )
    op.create_index(op.f("ix_users_device_id"), "users", ["device_id"], unique=False)

    op.create_table(
        "chats",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "category",
            sa.Enum("transport", "store", "hotel", "misc", name="category_type"),
            nullable=False,
        ),
        sa.Column(
            "form_type",
            sa.Enum(
                "airport", "cab", "bus", "hotel", "store", "misc_generic",
                name="form_type",
            ),
            nullable=False,
        ),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("subtitle", sa.String(255), nullable=True),
        sa.Column("country_code", sa.String(3), nullable=False, server_default="ID"),
        sa.Column("context_answers", postgresql.JSONB, nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_chats")),
    )
    op.create_index(op.f("ix_chats_user_id"), "chats", ["user_id"], unique=False)
    op.create_index(
        "ix_chats_user_active_updated_at",
        "chats",
        ["user_id", "is_active", "updated_at"],
        unique=False,
    )
    op.create_index(
        "ix_chats_user_category_active_updated_at",
        "chats",
        ["user_id", "category", "is_active", "updated_at"],
        unique=False,
    )

    op.create_table(
        "messages",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "chat_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("chats.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "sender",
            sa.Enum("user", "ai", "system", name="message_sender"),
            nullable=False,
        ),
        sa.Column("text", sa.String(4000), nullable=False),
        sa.Column("is_transcribed", sa.Boolean, nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_messages")),
    )
    op.create_index(op.f("ix_messages_chat_id"), "messages", ["chat_id"], unique=False)
    op.create_index(
        "ix_messages_chat_id_created_at",
        "messages",
        ["chat_id", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_messages_chat_id_created_at", table_name="messages")
    op.drop_index(op.f("ix_messages_chat_id"), table_name="messages")
    op.drop_index("ix_chats_user_category_active_updated_at", table_name="chats")
    op.drop_index("ix_chats_user_active_updated_at", table_name="chats")
    op.drop_index(op.f("ix_chats_user_id"), table_name="chats")
    op.drop_index(op.f("ix_users_device_id"), table_name="users")
    op.drop_table("messages")
    op.drop_table("chats")
    op.drop_table("users")
    op.execute("DROP TYPE IF EXISTS message_sender")
    op.execute("DROP TYPE IF EXISTS form_type")
    op.execute("DROP TYPE IF EXISTS category_type")
