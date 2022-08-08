"""DB のテーブル定義"""
from sqlalchemy import Column, ForeignKey, Integer, String, DateTime
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(32), unique=True, index=True)


class Work(Base):
    __tablename__ = "works"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(128), unique=True, index=True)


class Review(Base):
    __tablename__ = "reviews"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    work_id = Column(Integer, ForeignKey("works.id", ondelete="CASCADE"))
    star = Column(Integer)
    text = Column(String(4096))
    created_at = Column(DateTime, nullable=False)
    deleted_at = Column(DateTime, nullable=True)  # 論理削除フラグ