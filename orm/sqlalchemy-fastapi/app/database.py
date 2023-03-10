from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import Settings


setting = Settings()
SQLALCHEMY_DATABASE_BASE = (
    "mysql+pymysql://"
    + f"{setting.db_user}:{setting.MYSQL_ROOT_PASSWORD}@{setting.db_host}"
)
SQLALCHEMY_DATABASE_URL = SQLALCHEMY_DATABASE_BASE + f"/{setting.MYSQL_DATABASE}"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
