from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List

from database import SessionLocal, engine
import models, schemas, crud
from auth import authenticate_user, create_access_token



models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Yaşlı ve Engelli Bakım Platformu API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)

@app.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token({"sub": user.email})
    return {"access_token": token, "token_type": "bearer"}

@app.get("/jobs/", response_model=List[schemas.Job])
def read_jobs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_jobs(db, skip=skip, limit=limit)

@app.post("/jobs/", response_model=schemas.Job)
def create_job(job: schemas.JobCreate, owner_id: int = 1, db: Session = Depends(get_db)):
    return crud.create_job(db=db, job=job, owner_id=owner_id)

@app.get("/jobs/{job_id}", response_model=schemas.Job)
def get_job_detail(job_id: int, db: Session = Depends(get_db)):
    db_job = crud.get_job(db, job_id=job_id)
    if db_job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    return db_job


@app.post("/jobs/{job_id}/applications", response_model=schemas.JobApplication)
def create_job_application(job_id: int, application: schemas.JobApplicationCreate, db: Session = Depends(get_db)):
    created_app = crud.create_job_application(db, job_id=job_id, application=application)
    return schemas.JobApplication.from_orm(created_app)


@app.get("/employer/{employer_id}/unread_applications")
def get_unread_applications(employer_id: int, db: Session = Depends(get_db)):
    applications = db.query(models.JobApplication)\
        .join(models.Job, models.Job.id == models.JobApplication.job_id)\
        .join(models.User, models.User.id == models.JobApplication.user_id)\
        .filter(models.Job.owner_id == employer_id, models.JobApplication.is_read == False)\
        .order_by(models.JobApplication.application_date.desc())\
        .all()

    return [
        {
            "user_name": app.user.full_name,
            "job_title": app.job.title,
            "applicationDate": app.application_date.isoformat()
        }
        for app in applications
    ]


# main.py veya routes dosyana ekle
@app.post("/employer/{employer_id}/mark_applications_read")
def mark_all_applications_as_read(employer_id: int, db: Session = Depends(get_db)):
    crud.mark_applications_as_read(db, employer_id)
    return {"message": "Başvurular okundu olarak işaretlendi"}

@app.get("/employer/{employer_id}/active_jobs")
def get_active_jobs(employer_id: int, db: Session = Depends(get_db)):
    return db.query(models.Job).filter(models.Job.owner_id == employer_id, models.Job.is_active == True).all()

@app.post("/ratings/", response_model=schemas.Rating)
def create_rating(rating: schemas.RatingCreate, db: Session = Depends(get_db)):
    return crud.create_rating(db, rating)