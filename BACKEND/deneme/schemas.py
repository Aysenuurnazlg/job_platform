from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List

# ----------------------
# Kullanıcı Şemaları
# ----------------------
class UserBase(BaseModel):
    email: str
    full_name: str
    phone_number: str
    bio: Optional[str] = None

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
        orm_mode = True

class JobDetailBase(BaseModel):
    full_description: str
    requirements: str
    benefits: str
    hours_per_week: int

class JobDetailCreate(JobDetailBase):
    pass

class JobDetail(JobDetailBase):
    id: int
    job_id: int

    class Config:
        from_attributes = True

# ----------------------
# Başvuru Şemaları
# ----------------------
class JobApplication(BaseModel):
    id: int
    user_id: int = Field(..., alias="userId")
    application_date: datetime = Field(..., alias="applicationDate")
    job_id: int

    class Config:
        from_attributes = True
        validate_by_name = True

class JobApplicationCreate(BaseModel):
    user_id: int = Field(..., alias="userId")

    class Config:
        validate_by_name = True
