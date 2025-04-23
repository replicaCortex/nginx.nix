from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class UserInput(BaseModel):
    user_input: str


@app.post("/api")
def receive_input(data: UserInput):
    return {"result": f"Вы ввели: {data.user_input}"}


@app.get("/test")
def test():
    return "hi"
