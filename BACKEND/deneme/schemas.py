from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class UserBase(BaseModel):
    email: str
    full_name: str
    phone_number: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True

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
        orm_mode = True

class ReviewBase(BaseModel):
    rating: int
    comment: str
    user_id: int

class ReviewCreate(ReviewBase):
    pass

class Review(ReviewBase):
    id: int
    reviewer_id: int
    created_at: datetime

    class Config:
        orm_mode = True 