"""
Seed script to populate the database with initial data.
Run with: python -m app.seed
"""
import asyncio
import uuid

from app.database import async_session
from app.models import User, Chat, CategoryType, FormType


async def seed():
    async with async_session() as db:
        # Check if data already exists
        from sqlalchemy import select
        result = await db.execute(select(User).limit(1))
        if result.scalar_one_or_none():
            print("Database already seeded. Skipping.")
            return

        # Create demo user
        user = User(
            id=uuid.uuid4(),
            device_id="demo-device-001",
            display_name="Anna",
            preferences={"language": "en", "home_country": "ID"},
        )
        db.add(user)

        # Create sample chats
        sample_chats = [
            Chat(
                user_id=user.id,
                category=CategoryType.hotel,
                form_type=FormType.hotel,
                title="Famous Hotel",
                subtitle="Kuta, Bali",
                country_code="ID",
                context_answers={
                    "0": "Famous Hotel",
                    "1": "Anna Smith",
                    "2": "Jan 10, 2026 – Jan 14, 2026",
                    "3": "High floor, quiet room",
                    "4": "No allergies",
                    "5": "Check-in and checkout conversations",
                    "6": "",
                },
            ),
            Chat(
                user_id=user.id,
                category=CategoryType.transport,
                form_type=FormType.airport,
                title="CDG Airport",
                subtitle="Paris, France",
                country_code="FR",
                context_answers={
                    "0": "Garuda GA402",
                    "1": "Bali to Jakarta",
                    "2": "Window seat",
                    "3": "Nut allergy",
                    "4": "Yes",
                    "5": "Explaining I'm deaf",
                    "6": "",
                },
            ),
            Chat(
                user_id=user.id,
                category=CategoryType.store,
                form_type=FormType.store,
                title="Beachwalk Mall",
                subtitle="Kuta, Bali",
                country_code="ID",
                context_answers={
                    "0": "Souvenirs and batik shirts",
                    "1": "XL size, blue color",
                    "2": "500k IDR",
                    "3": "Mid-range",
                    "4": "Asking for prices and sizes",
                    "5": "",
                    "6": "",
                },
            ),
        ]
        db.add_all(sample_chats)
        await db.commit()
        print(f"Seeded {len(sample_chats)} chats for user {user.id}")


if __name__ == "__main__":
    asyncio.run(seed())
