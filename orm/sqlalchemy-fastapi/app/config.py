from typing import List
from pydantic import BaseSettings


class Settings(BaseSettings):
    allow_origins: List[str] = ["http://localhost:3000"]  # これは React とかを使うとき用
    db_name: str
    db_host: str
    db_user: str
    db_password: str

    class Config:
        env_file = ".env"
