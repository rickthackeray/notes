from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import database


app = FastAPI()


origins = ["http://10.1.1.*",
           "http://localhost",
           "http://localhost:3000",
           "http://notes-api.rickt.io",
           "https://notes-api.rickt.io"]

app.add_middleware(
    CORSMiddleware,
    allow_origins = ["*"],
    allow_credentials = True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/cards")
async def get_cards():
    response = await database.get_all_cards()
    return response

@app.post("/card")
async def add_card(title: str, description: str):
    card = {'title': title, 'description': description}
    response = await database.create_card(card)
    return response

@app.put("/card")
async def update_card(id: str, title: str, description: str):
    card = {'title': title, 'description': description}
    response = await database.update_card(id, card)
    return response


@app.delete("/card")
async def delete_card(id):
    response = await database.remove_card(id)
    return response
