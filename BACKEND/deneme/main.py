from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List
from sqlalchemy import func
from database import SessionLocal, engine
import models, schemas, crud
from auth import authenticate_user, create_access_token, get_current_user
from models import User
import datetime
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Yaşlı ve Engelli Bakım Platformu API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Karakter seti ayarı
@app.middleware("http")
async def add_charset_header(request, call_next):
    response = await call_next(request)
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    return response

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

@app.get("/users/me")
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@app.get("/users/{user_id}", response_model=schemas.UserProfileOut)
def get_user_profile(user_id: int, db: Session = Depends(get_db)):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    completed_jobs = db.query(func.avg(models.Rating.rating)).filter(models.Rating.receiver_id == user_id).scalar()
    rating = db.query(func.avg(models.Rating.rating)).filter_by(receiver_id=user_id).scalar() or 0.0
    job_types = ["Montaj", "Tesisat"]  # Dummy data
    reviews = db.query(models.Rating).filter_by(receiver_id=user_id).all()
    review_list = [
        {
            "name": db.query(models.User).get(rater.employer_id).full_name,
            "comment": rater.comment,
            "rating": rater.rating,
            "date": rater.created_at.strftime("%Y-%m-%d") if rater.created_at else datetime.datetime.utcnow().strftime("%Y-%m-%d")
        }
        for rater in reviews
    ]
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "phone_number": user.phone_number,
        "bio": user.bio,
        "rating": round(rating, 1),
        "completed_jobs": completed_jobs,
        "job_types": job_types,
        "reviews": review_list
    }

@app.put("/users/{user_id}")
def update_user(user_id: int, user_update: schemas.UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Sadece kendi profilini güncelleyebilir
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Bu işlem için yetkiniz yok")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    # E-posta değişiyorsa kontrol et
    if user_update.email != user.email:
        email_exists = db.query(User).filter(
            User.email == user_update.email,
            User.id != user_id
        ).first()
        if email_exists:
            raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kullanılıyor")
    
    # Kullanıcıyı güncelle
    for key, value in user_update.dict(exclude_unset=True).items():
        setattr(user, key, value)
    
    db.commit()
    db.refresh(user)
    
    # E-posta değiştiyse yeni token oluştur
    if user_update.email != user.email:
        new_token = create_access_token({"sub": user.email})
        return JSONResponse({
            "user": jsonable_encoder(user),
            "access_token": new_token,
            "token_type": "bearer"
        })
    
    return user

@app.get("/jobs/", response_model=List[schemas.Job])
def read_jobs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_jobs(db, skip=skip, limit=limit)

@app.post("/jobs/", response_model=schemas.Job)
def create_job(job: schemas.JobCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return crud.create_job(db=db, job=job, owner_id=current_user.id)

@app.get("/jobs/{job_id}", response_model=schemas.Job)
def get_job_detail(job_id: int, db: Session = Depends(get_db)):
    db_job = crud.get_job(db, job_id=job_id)
    if db_job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    return db_job

@app.post("/jobs/{job_id}/applications", response_model=schemas.JobApplication)
def create_job_application(
    job_id: int,
    application: schemas.JobApplicationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    created_app = crud.create_job_application(
        db=db,
        job_id=job_id,
        application=application,
        user_id=current_user.id
    )
    return schemas.JobApplication.from_orm(created_app)


@app.get("/employer/{employer_id}/all-jobs")
def get_all_employer_jobs(employer_id: int, db: Session = Depends(get_db)):
    jobs = db.query(models.Job).filter(models.Job.owner_id == employer_id).all()
    result = []

    for job in jobs:
        applications = db.query(models.JobApplication).filter(
            models.JobApplication.job_id == job.id
        ).all()

        basvuranlar = []
        for app in applications:
            user = db.query(models.User).filter(models.User.id == app.user_id).first()
            if not user:
                continue

            ratings = db.query(models.Rating).filter(models.Rating.receiver_id == user.id).all()
            ortalama_puan = sum(r.rating for r in ratings) / len(ratings) if ratings else 0

            yorumlar = []
            for rating in ratings:
                yazan = db.query(models.User).filter(models.User.id == rating.employer_id).first()
                if yazan:
                    yorumlar.append({
                        "yazan_kisi": yazan.full_name,
                        "yorum": rating.comment,
                        "puan": rating.rating,
                        "tarih": rating.created_at.strftime("%Y-%m-%d")
                    })

            basvuranlar.append({
                "basvuru_id": app.id,
                "kullanici": {
                    "id": user.id,
                    "isim": user.full_name,
                    "email": user.email,
                    "telefon": user.phone_number,
                    "bio": user.bio,
                    "ortalama_puan": round(ortalama_puan, 1),
                    "yorumlar": yorumlar
                },
                "basvuru_tarihi": app.application_date.strftime("%Y-%m-%d"),
                "basvuru_mesaji": app.message
            })

        result.append({
            "id": job.id,
            "title": job.title,
            "description": job.description,
            "worker_id": job.worker_id,
            "basvuranlar": basvuranlar
        })

    return result

@app.get("/employer/{employer_id}/notifications")
def get_employer_notifications(employer_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == employer_id).first()
    if not user:
        return []
    jobs = db.query(models.Job).filter(models.Job.owner_id == employer_id).all()
    if not jobs:
        return []
    applications = db.query(models.JobApplication)\
        .join(models.Job, models.Job.id == models.JobApplication.job_id)\
        .join(models.User, models.User.id == models.JobApplication.user_id)\
        .filter(models.Job.owner_id == employer_id)\
        .order_by(models.JobApplication.application_date.desc())\
        .all()
    if not applications:
        return []
    notifications = []
    for app in applications:
        try:
            notification = {
                "type": "new_application",
                "job_id": app.job.id,
                "job_title": app.job.title,
                "applicant_id": app.user.id,
                "applicant_name": app.user.full_name,
                "applicant_phone": app.user.phone_number,
                "application_date": app.application_date.isoformat(),
                "is_read": app.is_read,
                "application_id": app.id
            }
            notifications.append(notification)
        except:
            continue
    return notifications

@app.post("/employer/{employer_id}/mark_notification_read/{job_id}")
def mark_notification_as_read(employer_id: int, job_id: int, db: Session = Depends(get_db)):
    applications = db.query(models.JobApplication)\
        .join(models.Job, models.Job.id == models.JobApplication.job_id)\
        .filter(models.Job.owner_id == employer_id, models.Job.id == job_id)\
        .all()
    for app in applications:
        app.is_read = True
    db.commit()
    return {"message": "Bildirim okundu olarak işaretlendi"}

@app.get("/user/{user_id}/applications")
def get_user_applications(user_id: int, db: Session = Depends(get_db)):
    applications = db.query(models.JobApplication)\
        .join(models.Job, models.Job.id == models.JobApplication.job_id)\
        .filter(models.JobApplication.user_id == user_id)\
        .all()
    applied_jobs, accepted_jobs, completed_jobs = [], [], []
    for app in applications:
        job = app.job
        job_data = {
            "id": job.id,
            "title": job.title,
            "description": job.description,
            "location": job.location,
            "salary": job.salary,
            "application_date": app.application_date.isoformat()
        }
        if job.is_completed:
            completed_jobs.append(job_data)
        elif job.worker_id == user_id:
            accepted_jobs.append(job_data)
        else:
            applied_jobs.append(job_data)
    return {
        "applied": applied_jobs,
        "accepted": accepted_jobs,
        "completed": completed_jobs
    }

@app.post("/ratings/", response_model=schemas.Rating)
def create_rating(rating: schemas.RatingCreate, db: Session = Depends(get_db)):
    return crud.create_rating(db, rating)

# İşveren endpoint'leri
@app.get("/employer/{employer_id}/jobs")
def get_employer_jobs(employer_id: int, db: Session = Depends(get_db)):
    # Sadece worker_id'si olan (onaylanmış) işleri getir
    jobs = db.query(models.Job).filter(
        models.Job.owner_id == employer_id,
        models.Job.worker_id.isnot(None)  # worker_id'si olan işler
    ).all()
    result = []
    
    for job in jobs:
        worker_user = db.query(models.User).filter(models.User.id == job.worker_id).first()
        
        result.append({
            "id": job.id,
            "title": job.title,
            "description": job.description,
            "location": job.location,
            "salary": job.salary,
            "worker_id": job.worker_id,
            "worker_name": worker_user.full_name if worker_user else None,
            "is_completed": job.is_completed
        })
    
    return result

@app.post("/applications/{application_id}/approve")
def approve_application(application_id: int, db: Session = Depends(get_db)):
    # Başvuruyu bul
    application = db.query(models.JobApplication).filter(models.JobApplication.id == application_id).first()
    if not application:
        raise HTTPException(status_code=404, detail="Başvuru bulunamadı")
    
    # Başvuruyu onayla
    application.status = "onaylandi"
    
    # İşi güncelle
    job = db.query(models.Job).filter(models.Job.id == application.job_id).first()
    job.worker_id = application.user_id
    
    # Diğer başvuruları reddet
    db.query(models.JobApplication).filter(
        models.JobApplication.job_id == application.job_id,
        models.JobApplication.id != application_id
    ).update({"status": "reddedildi"})
    
    db.commit()
    
    return {"message": "Başvuru onaylandı ve diğer başvurular reddedildi"}

@app.post("/test-data/{employer_id}")
def create_test_data(employer_id: int, db: Session = Depends(get_db)):
    # Test iş ilanı oluştur
    test_job = models.Job(
        title="Test İş İlanı",
        description="Bu bir test iş ilanıdır",
        location="İstanbul",
        salary=5000.0,
        owner_id=employer_id,
        is_completed=False
    )
    db.add(test_job)
    db.commit()
    db.refresh(test_job)

    # Test iş detayı oluştur
    test_job_detail = models.JobDetail(
        job_id=test_job.id,
        full_description="Bu iş için detaylı açıklama",
        requirements="Deneyim ve referans",
        benefits="Esnek çalışma saatleri",
        hours_per_week=40,
        start_date=datetime.datetime.utcnow()
    )
    db.add(test_job_detail)
    db.commit()

    # Test başvuru oluştur (user_id=1 için)
    test_application = models.JobApplication(
        job_id=test_job.id,
        user_id=1,  # Test kullanıcı ID'si
        status="beklemede",
        message="Bu işe başvurmak istiyorum"
    )
    db.add(test_application)
    db.commit()

    return {"message": "Test verileri oluşturuldu", "job_id": test_job.id}

@app.post("/jobs/{job_id}/activate")
def activate_job(job_id: int, db: Session = Depends(get_db)):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="İlan bulunamadı")
    
    if job.worker_id is None:
        raise HTTPException(status_code=400, detail="İşe alınan çalışan olmadan ilan aktifleştirilemez")
    
    job.status = "active"
    db.commit()
    return {"message": "İlan aktifleştirildi"}

@app.post("/jobs/{job_id}/complete")
def complete_job(job_id: int, db: Session = Depends(get_db)):
    job = db.query(models.Job).filter(models.Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="İlan bulunamadı")
    
    if job.worker_id is None:
        raise HTTPException(status_code=400, detail="İşe alınan çalışan olmadan iş tamamlanamaz")
    
    job.is_completed = True
    db.commit()
    return {"message": "İş tamamlandı olarak işaretlendi"}
