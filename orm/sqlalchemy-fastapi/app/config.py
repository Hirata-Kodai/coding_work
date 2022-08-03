from typing import List
from pydantic import BaseSettings


class Settings(BaseSettings):
    allow_origins: List[str] = ["http://localhost:3000"]  # これは React とかを使うとき用

    class Config:
        env_file = ".env"
