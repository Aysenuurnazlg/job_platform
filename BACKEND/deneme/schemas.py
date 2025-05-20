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
        orm_mode = True

class ReviewOut(BaseModel):
    name: str
    comment: str
    rating: int
    date: str

class UserProfileOut(BaseModel):
    id: int
    full_name: str
    email: str
    phone_number: str
    bio: Optional[str]
    rating: float
    completed_jobs: Optional[int] = None
    job_types: List[str]
    reviews: List[ReviewOut]

    class Config:
        from_attributes = True
        orm_mode = True

class UserResponse(BaseModel):
    id: int
    full_name: str
    email: str
    phone_number: str
    bio: Optional[str]
    
    class Config:
        from_attributes = True
        orm_mode = True

class UserUpdate(BaseModel):
    full_name: str
    email: str
    phone_number: str
    bio: Optional[str] = None

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
        orm_mode = True

# ----------------------
# Başvuru Şemaları
# ----------------------
class JobApplication(BaseModel):
    id: int
    user_id: int
    application_date: datetime
    job_id: int

    class Config:
        from_attributes = True
        orm_mode = True

class JobApplicationCreate(BaseModel):
    user_id: int

    class Config:
        from_attributes = True
        orm_mode = True


class RatingCreate(BaseModel):
    employer_id: int
    worker_id: int
    job_id: int
    rating: int
    comment: str = ""
    receiver_id: Optional[int] = None

class Rating(BaseModel):
    id: int
    employer_id: int
    worker_id: int
    job_id: int
    rating: int
    comment: str
    receiver_id: int

    class Config:
        from_attributes = True
        orm_mode = True  # ORM nesnelerinden veri almak için gerekli