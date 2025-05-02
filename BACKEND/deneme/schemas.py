from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# Ortak alanlar
class UserBase(BaseModel):
    email: str
    full_name: str
    phone_number: str  # <-- eksik alan eklendi

# Yeni kullanıcı oluşturma
class UserCreate(UserBase):
    password: str

# Veritabanından gelen kullanıcı
class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# İş ilanları
class JobBase(BaseModel):
    title: str
    description: str
    location: str
    salary: float

class JobCreate(JobBase):
    pass

class Job(JobBase):
    id: int
    owner_id: int
    created_at: datetime

    class Config:
        from_attributes = True
