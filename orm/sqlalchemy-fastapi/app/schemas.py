"""API で扱うモデル定義"""
import datetime
from enum import Enum
from pydantic import BaseModel


class UserKey(str, Enum):
    id = "id"
    name = "name"


class WorkKey(str, Enum):
    id = "id"
    name = "name"


class RevieKey(str, Enum):
    id = "id"
    user_id = "user_id"
    work_id = "work_id"
    star = "star"
    text = "text"
    created_at = "created_at"
    deleted_at = "deleted_at"


class User(BaseModel):
    id: int
    name: str

    class Config:
        orm_mode = True

    @staticmethod
    def from_dict(source):
        return User(id=source[UserKey.id], name=source[UserKey.name])


class Work(BaseModel):
    id: int
    name: str

    class Config:
        orm_mode = True

    @staticmethod
    def from_dict(source):
        return Work(id=source[WorkKey.id], name=source[WorkKey.name])


class Review(BaseModel):
    id: int
    user_id: int
    work_id: int
    star: int
    text: str
    created_at: datetime.datetime
    deleted_at: datetime.datetime

    class Config:
        orm_mode = True

    @staticmethod
    def from_dict(source):
        return Review(
            id=source[RevieKey.id],
            user_id=source[RevieKey.user_id],
            work_id=source[RevieKey.work_id],
            star=source[RevieKey.star],
            text=source[RevieKey.text],
            created_at=source[RevieKey.created_at],
            deleted_at=None,
        )


class UserCreate(BaseModel):
    name: str


class WorkCreate(BaseModel):
    name: str


class ReviewCreate(BaseModel):
    user_id: int
    work_id: int
    star: int
    text: str
    created_at: datetime.datetime
    deleted_at: datetime.datetime
