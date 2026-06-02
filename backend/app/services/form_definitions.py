"""Form definitions mirroring ContextFormMockData.swift"""

from app.models.chat import FormType

FORM_DEFINITIONS: dict[FormType, dict] = {
    FormType.airport: {
        "title": "Flights",
        "icon_system_name": "airplane",
        "steps": [
            {"prompt": "What airline and flight are you taking?", "input_kind": "text", "placeholder": "e.g. Garuda GA402"},
            {"prompt": "Where are you flying from and to?", "input_kind": "text", "placeholder": "e.g. Bali to Jakarta"},
            {"prompt": "What seat do you prefer?", "input_kind": "text", "placeholder": "Window / Aisle"},
            {"prompt": "Do you have any food preferences or allergies?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Are you carrying check-in luggage?", "input_kind": "yes_no", "placeholder": "Yes / No"},
            {"prompt": "Is there anything you usually need help communicating?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Add anything important AI should remember for this trip.", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
    FormType.cab: {
        "title": "Cab / Ride hailing",
        "icon_system_name": "car.fill",
        "steps": [
            {"prompt": "Where are you going today?", "input_kind": "text", "placeholder": "Destination"},
            {"prompt": "Do you usually prefer silent rides?", "input_kind": "yes_no", "placeholder": "Yes / No"},
            {"prompt": "Do you need frequent stops or route changes?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Are you carrying luggage or large bags?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Is there anything drivers often misunderstand about your instructions?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "What payment method will you use?", "input_kind": "text", "placeholder": "Cash / Card / App"},
            {"prompt": "Add anything important AI should remember for this ride.", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
    FormType.bus: {
        "title": "Bus",
        "icon_system_name": "bus.fill",
        "steps": [
            {"prompt": "What is your destination?", "input_kind": "text", "placeholder": "Destination"},
            {"prompt": "Which bus/company/route are you taking?", "input_kind": "text", "placeholder": "Route name"},
            {"prompt": "Do you prefer window or aisle seats?", "input_kind": "text", "placeholder": "Window / Aisle"},
            {"prompt": "Do you usually ask drivers about stops or timings?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Are you carrying luggage?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Is there anything important about this journey AI should know?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Add anything AI should help communicate during the trip.", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
    FormType.hotel: {
        "title": "Hotel",
        "icon_system_name": "bed.double.fill",
        "steps": [
            {"prompt": "What hotel are you staying at?", "input_kind": "text", "placeholder": "Hotel name"},
            {"prompt": "What name is the booking under?", "input_kind": "text", "placeholder": "Booking name"},
            {"prompt": "What are your check-in and check-out dates?", "input_kind": "date_range", "placeholder": "Dates"},
            {"prompt": "Do you have room preferences?", "input_kind": "text", "placeholder": "Your preferences"},
            {"prompt": "Do you have food preferences or allergies?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "What do you usually need help communicating at hotels?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Add anything important AI should remember during your stay.", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
    FormType.store: {
        "title": "Store",
        "icon_system_name": "cart.fill",
        "steps": [
            {"prompt": "What are you shopping for today?", "input_kind": "text", "placeholder": "Items"},
            {"prompt": "What size, color, or model are you looking for?", "input_kind": "text", "placeholder": "Details"},
            {"prompt": "What is your budget?", "input_kind": "text", "placeholder": "Budget"},
            {"prompt": "Do you prefer premium or affordable options?", "input_kind": "text", "placeholder": "Your preference"},
            {"prompt": "What questions do you usually need help asking in stores?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Are there any products or materials you avoid?", "input_kind": "text", "placeholder": "Your answer"},
            {"prompt": "Add anything AI should remember while helping you shop.", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
    FormType.misc_generic: {
        "title": "Misc",
        "icon_system_name": "message.fill",
        "steps": [
            {"prompt": "What do you need help with today?", "input_kind": "text", "placeholder": "Topic"},
            {"prompt": "Where are you right now?", "input_kind": "text", "placeholder": "Location"},
            {"prompt": "What should AI help you communicate?", "input_kind": "text", "placeholder": "Your answer"},
        ],
    },
}


def get_form_definition(form_type: FormType) -> dict:
    """Return the form definition for a given form type, or None if not found."""
    return FORM_DEFINITIONS.get(form_type)


def humanize_context(form_type: FormType, context_answers: dict | None) -> dict[str, str]:
    """Convert index-keyed context_answers ({"0": "Garuda GA402", "1": "Bali→Jakarta", ...})
    into prompt-keyed answers ({"What airline and flight are you taking?": "Garuda GA402", ...}).

    Empty answers are filtered out. Used when building prompts for OpenAI so the AI sees
    meaningful labels instead of bare indices.
    """
    if not context_answers:
        return {}

    definition = FORM_DEFINITIONS.get(form_type)
    if not definition:
        # No form definition → return values as-is (already have meaningful keys?)
        return {k: v for k, v in context_answers.items() if v}

    steps = definition["steps"]
    result: dict[str, str] = {}

    for key, value in context_answers.items():
        if not value or not str(value).strip():
            continue
        try:
            index = int(key)
            if 0 <= index < len(steps):
                label = steps[index]["prompt"]
            else:
                label = key  # out of range, keep original
        except (ValueError, TypeError):
            label = key  # non-numeric key, keep as-is

        result[label] = str(value)

    return result
