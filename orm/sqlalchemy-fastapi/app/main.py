from typing import List
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
import crud
import models, schemas
from schemas import UserCreate, WorkCreate, ReviewCreate
from database import SessionLocal, engine


models.Base.metadata.create_all(bind=engine)
app = FastAPI()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"msg": "Server running"}


@app.get("/user", response_model=List[schemas.User])
async def get_user(db: Session = Depends(get_db)):
    return crud.get_users(db)


@app.post("/user", response_model=schemas.User)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return crud.create_user(db, user)
