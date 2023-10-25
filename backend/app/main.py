from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from mangum import Mangum
import database
import uvicorn


app = FastAPI()
handler = Mangum(app)

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

@app.get("/")
async def root():
    return {"root works..."}

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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)