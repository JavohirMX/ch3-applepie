from pydantic import BaseModel


class FormStepResponse(BaseModel):
    index: int
    prompt: str
    input_kind: str  # "text" | "yes_no" | "date_range"
    placeholder: str


class FormDefinitionResponse(BaseModel):
    form_type: str
    title: str
    icon_system_name: str
    steps: list[FormStepResponse]


class SuggestionRequest(BaseModel):
    pass  # conversation context is taken from the DB


class SuggestionResponse(BaseModel):
    phrases: list[str]
