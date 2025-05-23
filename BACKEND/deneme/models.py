from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Float, DateTime
from sqlalchemy.orm import relationship, Mapped, mapped_column
from database import Base
import datetime  # <-- sadece bu gerekli
from typing import List, Optional


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(100))
    phone_number: Mapped[str] = mapped_column(String(20)) 
    bio: Mapped[Optional[str]] = mapped_column(String(255), default="") 
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)

    jobs = relationship("Job", back_populates="owner", foreign_keys="Job.owner_id")
    applications = relationship("JobApplication", back_populates="user")
    ratings_given = relationship("Rating", back_populates="employer", foreign_keys="Rating.employer_id")
    ratings_received = relationship("Rating", back_populates="worker", foreign_keys="Rating.worker_id")


class Job(Base):
    __tablename__ = "jobs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(100))
    description: Mapped[str] = mapped_column(String(255))
    location: Mapped[str] = mapped_column(String(100))
    salary: Mapped[float] = mapped_column(Float)
    owner_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)
    worker_id: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    
    owner = relationship("User", back_populates="jobs", foreign_keys=[owner_id])
    worker = relationship("User", foreign_keys=[worker_id])
    
    detail = relationship("JobDetail", uselist=False, back_populates="job")
    applications = relationship("JobApplication", back_populates="job")
    ratings = relationship("Rating", back_populates="job")


class JobDetail(Base):
    __tablename__ = "job_details"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    job_id: Mapped[int] = mapped_column(Integer, ForeignKey("jobs.id"))  # ForeignKey ile Job tablosuna bağlanıyor
    full_description: Mapped[str] = mapped_column(String(1000))  # İşin detaylı açıklaması
    requirements: Mapped[str] = mapped_column(String(500))  # İş için gereksinimler
    benefits: Mapped[str] = mapped_column(String(500))  # İşin sunduğu avantajlar
    hours_per_week: Mapped[int] = mapped_column(Integer)  # Haftalık çalışma saati
    start_date: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)  # İşin başlangıç tarihi
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)

    job = relationship("Job", back_populates="detail")  # Job ile 
    
#onaylanan iş
class JobApplication(Base):
    __tablename__ = "job_applications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    job_id: Mapped[int] = mapped_column(Integer, ForeignKey("jobs.id"))
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    application_date: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)
    status: Mapped[str] = mapped_column(String, default="beklemede")  # beklemede, onaylandi, reddedildi
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    message: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    job = relationship("Job", back_populates="applications")
    user = relationship("User", back_populates="applications")

class Rating(Base):
    __tablename__= "ratings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    employer_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    worker_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    job_id: Mapped[int] = mapped_column(Integer, ForeignKey("jobs.id"))
    rating: Mapped[int] = mapped_column(Integer)
    comment: Mapped[str] = mapped_column(String(1000), default="")
    receiver_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, default=datetime.datetime.utcnow)

    # İlişkiler
    employer = relationship("User", foreign_keys=[employer_id])
    worker = relationship("User", foreign_keys=[worker_id])
    receiver = relationship("User", foreign_keys=[receiver_id])
    job = relationship("Job")