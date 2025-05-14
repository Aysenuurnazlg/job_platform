from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# MySQL bağlantı bilgilerini burada güncelleyin
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://aysenurr:Ayci7784a.@127.0.0.1/job"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base() 