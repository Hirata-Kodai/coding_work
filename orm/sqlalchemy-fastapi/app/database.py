from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import Settings


setting = Settings()
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://" +\
    f"{setting.db_user}:{setting.db_password}@{setting.db_host}"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
engine.execute(f"CREATE DATABASE IF NOT EXISTS {setting.db_name}")  # SQLalchemy_utils を使うとデータベースも作成できるらしいがとりあえず生 SQL
engine.execute(f"USE {setting.db_name}")
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
