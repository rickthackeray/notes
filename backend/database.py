import os
from bson import ObjectId

import pydantic
import motor.motor_asyncio
from dotenv import load_dotenv

pydantic.json.ENCODERS_BY_TYPE[ObjectId]=str


load_dotenv("keys.env")
mongo_user = os.getenv("MONGO_USER")
mongo_pass = os.getenv("MONGO_PASS")

uri = 'mongodb+srv://' + mongo_user + ':' + mongo_pass + '@cluster0.4ybbrum.mongodb.net/?retryWrites=true&w=majority'
client = motor.motor_asyncio.AsyncIOMotorClient(uri)
database = client.notes
collection = database.board01


async def get_all_cards():
    cards = []
    cursor = collection.find({})
    async for document in cursor:
        cards.append(document)
    return cards

async def create_card(card):
    result = await collection.insert_one(card)
    return card

async def update_card(id, card):
    document = card
    await collection.replace_one({"_id": ObjectId(id)}, document)
    return document

async def remove_card(id):
    await collection.delete_one({"_id": ObjectId(id)})
    return True