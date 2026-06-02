from pydantic_settings import BaseSettings
from pydantic import Field, field_validator


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://conversa:conversa@db:5432/conversa"
    llm_api_key: str = Field(min_length=1)
    llm_base_url: str | None = None
    llm_model: str = Field(min_length=1)
    llm_reply_max_tokens: int = Field(default=300, ge=1)
    llm_reply_temperature: float = Field(default=0.7, ge=0, le=2)
    llm_suggestions_max_tokens: int = Field(default=200, ge=1)
    llm_suggestions_temperature: float = Field(default=0.8, ge=0, le=2)
    app_env: str = "development"
    debug: bool = False
    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost", "http://127.0.0.1"])

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}

    @field_validator("llm_base_url", mode="before")
    @classmethod
    def normalize_base_url(cls, value: str | None) -> str | None:
        if value is None:
            return None
        stripped = value.strip()
        return stripped or None


settings = Settings()
