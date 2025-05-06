from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# ----------------------
# Kullanıcı Şemaları
# ----------------------
class UserBase(BaseModel):
    email: str
    full_name: str
    phone_number: str
    bio: Optional[str] = ""

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    full_name: str
    email: str
    phone_number: str
    bio: str

# ----------------------
# İş İlanı Şemaları
# ----------------------
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
