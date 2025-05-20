from sqlalchemy.orm import Session
import schemas
import models
from models import JobApplication
from passlib.context import CryptContext
import datetime
from schemas import RatingCreate
from fastapi import HTTPException

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
        bio=user.bio,
        hashed_password=hashed_pw,
        created_at=datetime.datetime.utcnow(),
        is_active=True
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return schemas.User.from_orm(db_user)


# Tüm kullanıcıları getir
def get_users(db: Session, skip: int = 0, limit: int = 100):
    users = db.query(models.User).offset(skip).limit(limit).all()
    return [schemas.User.from_orm(user) for user in users]


# Tek bir kullanıcıyı ID ile getir
def get_user_by_id(db: Session, user_id: int):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if db_user is None:
        return None
    return schemas.User.from_orm(db_user)


def update_user(db: Session, user_id: int, user_update: schemas.UserUpdate):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None

    if user_update.email and user_update.email != user.email:
        email_exists = db.query(models.User).filter(
            models.User.email == user_update.email,
            models.User.id != user_id
        ).first()
        if email_exists:
            raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kullanılıyor.")

    for key, value in user_update.dict(exclude_unset=True).items():
        setattr(user, key, value)

    db.commit()
    db.refresh(user)
    return user


# Yeni iş ilanı oluştur
def create_job(db: Session, job: schemas.JobCreate, owner_id: int):
    db_job = models.Job(
        title=job.title,
        description=job.description,
        location=job.location,
        salary=job.salary,
        owner_id=owner_id,
        created_at=datetime.datetime.utcnow()
    )
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return schemas.Job.from_orm(db_job)


# Tüm iş ilanlarını getir
def get_jobs(db: Session, skip: int = 0, limit: int = 100):
    jobs = db.query(models.Job).offset(skip).limit(limit).all()
    return [schemas.Job.from_orm(job) for job in jobs]


# Tek bir iş ilanını ID ile getir
def get_job(db: Session, job_id: int):
    db_job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if db_job is None:
        return None
    return schemas.Job.from_orm(db_job)


# Yeni iş başvurusu oluştur (user_id artık dışarıdan gelir, güvenlidir)
def create_job_application(db: Session, job_id: int, application: schemas.JobApplicationCreate, user_id: int):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    db_application = models.JobApplication(
        job_id=job_id,
        user_id=user_id,  # Artık token'dan gelen user_id kullanılıyor
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


# Başvuruları okundu olarak işaretle
def mark_applications_as_read(db: Session, employer_id: int):
    unread_apps = get_unread_applications_for_employer(db, employer_id)
    for app in unread_apps:
        app.is_read = True
    db.commit()


# Puanlama (rating) oluştur
def create_rating(db: Session, rating: RatingCreate):
    db_rating = models.Rating(
        employer_id=rating.employer_id,
        worker_id=rating.worker_id,
        job_id=rating.job_id,
        rating=rating.rating,
        comment=rating.comment,
        receiver_id=rating.receiver_id or rating.worker_id  # receiver_id yoksa worker_id'yi kullan
    )
    db.add(db_rating)
    db.commit()
    db.refresh(db_rating)
    return db_rating


# İşverene ait aktif işleri getir
def get_active_jobs(db: Session, employer_id: int):
    return db.query(models.Job).filter(models.Job.owner_id == employer_id).all()
