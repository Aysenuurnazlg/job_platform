from sqlalchemy.orm import Session
import schemas
import models
from models import JobApplication
from passlib.context import CryptContext
import datetime


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Kullanıcıyı e-posta ile getir
def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

# Yeni kullanıcı oluştur
def create_user(db: Session, user: schemas.UserCreate):
    hashed_pw = pwd_context.hash(user.password)
    db_user = models.User(
        email=user.email,
        full_name=user.full_name,
        phone_number=user.phone_number,
        hashed_password=hashed_pw,
        created_at=datetime.datetime.utcnow(),
        is_active=True
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# Tüm kullanıcıları getir
def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

# Tek bir kullanıcıyı ID ile getir
def get_user_by_id(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

# Kullanıcı bilgilerini güncelle
def update_user(db: Session, user_id: int, user_update: schemas.UserUpdate):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None

    user.full_name = user_update.full_name
    user.email = user_update.email
    user.phone_number = user_update.phone_number
    user.bio = user_update.bio

    db.commit()
    db.refresh(user)
    return user

# Yeni iş ilanı oluştur
def create_job(db: Session, job: schemas.JobCreate, owner_id: int):
    db_job = models.Job(**job.dict(), owner_id=owner_id)
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return db_job

# Tüm iş ilanlarını getir
def get_jobs(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Job).offset(skip).limit(limit).all()


# get_job fonksiyonunu ekleyin
def get_job(db: Session, job_id: int):
    return db.query(models.Job).filter(models.Job.id == job_id).first()


def create_job_application(db: Session, job_id: int, application: schemas.JobApplicationCreate):
    db_application = JobApplication(
        job_id=job_id,
        user_id=application.user_id,
        application_date=datetime.datetime.utcnow(),
        is_read=False
    )
    db.add(db_application)
    db.commit()
    db.refresh(db_application)
    return db_application




# Okunmamış başvuruları getir
def get_unread_applications_for_employer(db: Session, employer_id: int):
    return db.query(models.JobApplication).join(models.Job).filter(
        models.Job.owner_id == employer_id,
        models.JobApplication.is_read == False
    ).all()

# Okundu olarak işaretle
def mark_applications_as_read(db: Session, employer_id: int):
    unread_apps = get_unread_applications_for_employer(db, employer_id)
    for app in unread_apps:
        app.is_read = True
    db.commit()