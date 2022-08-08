from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import Settings


setting = Settings()
# この時点では存在していないデータベースを選択しても問題ない
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://" +\
    f"{setting.db_user}:{setting.db_password}@{setting.db_host}/{setting.db_name}"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
