from sqlalchemy.orm import Session
import models, schemas
from schemas import UserCreate, WorkCreate, ReviewCreate
from fastapi import HTTPException


# 一覧取得
def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def get_works(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Work).offset(skip).limit(limit).all()


def get_reviews(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Review).offset(skip).limit(limit).all()


# 個別取得
def get_user_by_id(db: Session, id: int):
    return db.query(models.User)\
             .filter(models.User.id == id)\
             .all()


def get_work_by_id(db: Session, id: int):
    return db.query(models.Work)\
             .filter(models.Work.id == id)\
             .all()


def get_review_by_id(db: Session, id: int):
    return db.query(models.Review)\
             .filter(models.Review.id == id)\
             .all()


# 作成
def create_user(db: Session, user: UserCreate):
    new_user = models.User(name=user.name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
