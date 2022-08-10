from typing import List
from pydantic import BaseSettings


class Settings(BaseSettings):
    allow_origins: List[str] = ["http://localhost:3000"]  # これは React とかを使うとき用
    MYSQL_DATABASE: str
    db_host: str
    db_user: str
    MYSQL_ROOT_PASSWORD: str

    class Config:
        env_file = ".env"
