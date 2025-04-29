from fastapi import FastAPI, HTTPException, Depends, UploadFile, File
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import declarative_base, relationship, sessionmaker,Session
from datetime import datetime
import pyrebase
import shutil
import re
import os
import dotenv



# .env dosyasını yükle
dotenv.load_dotenv()

# Firebase yapılandırması
firebaseConfig = {
    'apiKey': os.getenv("FIREBASE_API_KEY"),
    'authDomain': os.getenv("FIREBASE_AUTH_DOMAIN"),
    'projectId': os.getenv("FIREBASE_PROJECT_ID"),
    'storageBucket': os.getenv("FIREBASE_STORAGE_BUCKET"),
    'messagingSenderId': os.getenv("FIREBASE_MESSAGING_SENDER_ID"),
    'appId': os.getenv("FIREBASE_APP_ID"),
    'databaseURL': os.getenv("FIREBASE_DATABASE_URL")
}
firebase = pyrebase.initialize_app(firebaseConfig)
auth = firebase.auth()

# SQLAlchemy ORM yapılandırması
Base = declarative_base()
# Kullanıcı tablosu
class Kullanici(Base):
    __tablename__ = 'kullanicilar'
    id = Column(Integer, primary_key=True)
    firebase_uid = Column(String(100), unique=True, nullable=False)
    isim = Column(String(50))
    email = Column(String(100), unique=True)
    telefon = Column(String(15))
    rol = Column(String(20))

    basvurular = relationship("Basvuru", back_populates="kullanici")
    profil_bilgileri = relationship("ProfilBilgileri", back_populates="kullanici")

    def __repr__(self):
        return f"<Kullanici(id={self.id}, isim={self.isim}, email={self.email}, rol={self.rol})>"
# İş ilanları tablosu
class IsIlani(Base):
    __tablename__ = 'is_ilanlari'
    id = Column(Integer, primary_key=True)
    baslik = Column(String(100))
    aciklama = Column(String(500))
    yayin_tarihi = Column(DateTime, default=datetime.utcnow)
    ratings = relationship("Rating", back_populates="job")

    basvurular = relationship("Basvuru", back_populates="is_ilani")

    def __repr__(self):
        return f"<IsIlani(id={self.id}, baslik={self.baslik}, yayin_tarihi={self.yayin_tarihi})>"
# Kullanıcı Puanlama (POST /rate_user)
class Rating(Base):
    __tablename__ = 'ratings'
    id = Column(Integer, primary_key=True)
    from_user_id = Column(Integer, ForeignKey('kullanicilar.id'))
    to_user_id = Column(Integer, ForeignKey('kullanicilar.id'))
    job_id = Column(Integer, ForeignKey('is_ilanlari.id'))
    rating = Column(Integer)  # Puan (1-5 arası)
    yorum = Column(String(500))
    job = relationship("IsIlani", back_populates="ratings")

    from_user = relationship("Kullanici", foreign_keys=[from_user_id])
    to_user = relationship("Kullanici", foreign_keys=[to_user_id])
# iş Başvuru tablosu
class Basvuru(Base):
    __tablename__ = 'basvurular'
    id = Column(Integer, primary_key=True)
    kullanici_id = Column(Integer, ForeignKey('kullanicilar.id'))
    is_ilani_id = Column(Integer, ForeignKey('is_ilanlari.id'))
    basvuru_tarihi = Column(DateTime, default=datetime.utcnow)
    durum = Column(String(20), default="beklemede")

    kullanici = relationship("Kullanici", back_populates="basvurular")
    is_ilani = relationship("IsIlani", back_populates="basvurular")

    def __repr__(self):
        return f"<Basvuru(id={self.id}, kullanici_id={self.kullanici_id}, is_ilani_id={self.is_ilani_id}, durum={self.durum})>"


# Kullancı profil bilgileri tablosu
class ProfilBilgileri(Base):
    __tablename__ = 'profil_bilgileri'
    id = Column(Integer, primary_key=True)
    kullanici_id = Column(Integer, ForeignKey('kullanicilar.id'))
    adres = Column(String(200))
    dogum_tarihi = Column(DateTime)
    photo_url = Column(String(200))

    kullanici = relationship("Kullanici", back_populates="profil_bilgileri")

    def __repr__(self):
        return f"<ProfilBilgileri(id={self.id}, kullanici_id={self.kullanici_id}, adres={self.adres}, dogum_tarihi={self.dogum_tarihi})>"


# Veritabanı bağlantısı
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL ortam değişkeni tanimli değil! Lütfen .env dosyasini kontrol edin.")
engine = create_engine(DATABASE_URL, echo=True)
try:
    with engine.connect() as connection:
        print("Veritabanı bağlantısı başarılı!")
except Exception as e:
    print(f"Veritabanı bağlantısı hatası: {str(e)}")
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Veritabanı bağımlılığı
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Yardımcı doğrulama fonksiyonları(e-posta ve şifre)
def is_valid_email(email):
    return bool(re.match(r"[^@]+@[^@]+\.[^@]+", email))

def is_strong_password(password):
    return (
        len(password) >= 8 and
        any(c.islower() for c in password) and
        any(c.isupper() for c in password) and
        any(c.isdigit() for c in password) and
        any(c in "!@#$%^&*()-_+=<>?/" for c in password)
    )

# FastAPI uygulaması
app = FastAPI()
# Tabloları sil (sadece geliştirme ortamında!)
#Base.metadata.drop_all(bind=engine)

# Tabloları yeniden oluştur
Base.metadata.create_all(bind=engine)
# FastAPI uygulaması başlamadan önce tabloları oluştur
Base.metadata.create_all(bind=engine)
@app.get("/")
def read_root():
   return {"message": "Ana sayfaya hoş geldiniz!"}

# Kullanıcı Kayıt (POST /register)
class KullaniciKayit(BaseModel):
    email: str
    password: str
    phone: str
    role: str

@app.post("/register")
def register_user(user: KullaniciKayit, db: Session = Depends(get_db)):
    if not is_valid_email(user.email):
        raise HTTPException(status_code=400, detail="Geçersiz e-posta!")

    existing_user = db.query(Kullanici).filter(Kullanici.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kayitli.")
    
    if not is_strong_password(user.password):
        raise HTTPException(status_code=400, detail="Şifre çok zayif!")
    
    try:
        firebase_user = auth.create_user_with_email_and_password(user.email, user.password)
        firebase_uid = firebase_user["localId"]
        
        yeni_kullanici = Kullanici(firebase_uid=firebase_uid, isim=user.email.split('@')[0], email=user.email, telefon=user.phone, rol=user.role)
        
        db.add(yeni_kullanici)
        db.commit()
        
        return {"message": f"{user.email} başariyla kaydedildi!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Kayit sirasinda hata oluştu: {str(e)}")

# Kullanıcı Giriş (POST /login)
class KullaniciGiris(BaseModel):
    email: str
    password: str

@app.post("/login")
def login_user(user: KullaniciGiris):
    try:
        user_data = auth.sign_in_with_email_and_password(user.email, user.password)
        return {"message": "Başariyla giriş yapildi!", "token": user_data["idToken"]}
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Giriş başarisiz: {str(e)}")

# İş İlanları (GET /jobs)
@app.get("/jobs")
def get_jobs(db: Session = Depends(get_db)):
    jobs = db.query(IsIlani).all()
    if not jobs:  # Eğer iş ilanları bulunamazsa
        raise HTTPException(status_code=404, detail="İş ilani bulunamadi.")
    return {"jobs": [job.__dict__ for job in jobs]}

# İş Başvurusu (POST /apply_job)
class BasvuruModel(BaseModel):
    user_id: int
    job_id: int

@app.post("/apply_job")
def apply_job(application: BasvuruModel, db: Session = Depends(get_db)):
    user = db.query(Kullanici).filter(Kullanici.id == application.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    job = db.query(IsIlani).filter(IsIlani.id == application.job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    yeni_basvuru = Basvuru(kullanici_id=application.user_id, is_ilani_id=application.job_id)
    db.add(yeni_basvuru)
    db.commit()
    return {"message": "Başvuru başariyla tamamlandi!"}

# Şifre Güncelleme (PUT /update_password) 
class PasswordUpdate(BaseModel):
    email: str
    old_password: str
    new_password: str

@app.put("/update_password")
def update_password(password_data: PasswordUpdate):
    try:
        auth.send_password_reset_email(password_data.email)
        return {"message": "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi!"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Hata: {str(e)}")
# Şifre Güncelleme 
'''
@app.put("/update_password/{user_id}") ()
def update_password(user_id: int, password_data: PasswordUpdate, db: Session = Depends(get_db)):
    # Firebase kimlik doğrulaması
    try:
        user = auth.sign_in_with_email_and_password(password_data.email, password_data.old_password)
        auth.update_user_password(user["idToken"], password_data.new_password)
        
        return {"message": "Şifre başarıyla güncellendi!"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Hata: {str(e)}")
'''
#Profil görünteleme
@app.get("/profile/{user_id}")
def gett_profile(user_id: int, db: Session = Depends(get_db)):
    profile = db.query(Kullanici).filter(Kullanici.id == user_id).first()
    if profile:
        # Kullanıcı profili detaylarını içeren veriyi döndürüyoruz
        profile_data = {
            "isim": profile.isim,
            "email": profile.email,
            "telefon": profile.telefon,
            "rol": profile.rol,
            "photo_url": profile.profil_bilgileri[0].photo_url if profile.profil_bilgileri else None,
            "rating": calculate_user_rating(user_id, db),
            "past_jobs": get_user_past_jobs(user_id, db),
        }
        return {"profile": profile_data}
    else:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")
# Profil Güncelleme (PUT /profile/{user_id})
class ProfilGuncelleme(BaseModel):
    isim: str
    telefon: str
    rol: str
    photo_url: str = None  # Fotoğraf URL'si opsiyonel
    adres: str = None  # Adres opsiyonel
    dogum_tarihi: str = None  # Doğum tarihi opsiyonel (YYYY-MM-DD formatında)

@app.put("/update_profile/{user_id}")
def update_profile(user_id: int, updated_profile: ProfilGuncelleme, db: Session = Depends(get_db)):
    profile = db.query(Kullanici).filter(Kullanici.id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")

    profile.isim = updated_profile.isim
    profile.telefon = updated_profile.telefon
    profile.rol = updated_profile.rol
    profile_info = db.query(ProfilBilgileri).filter(ProfilBilgileri.kullanici_id == user_id).first()
  
    if profile_info:
        if updated_profile.adres:
            profile_info.adres = updated_profile.adres
        if updated_profile.dogum_tarihi:
            profile_info.dogum_tarihi = updated_profile.dogum_tarihi
        if updated_profile.photo_url:
            profile_info.photo_url = updated_profile.photo_url
    else:
        # Profil bilgileri yoksa yeni bir profil bilgisi oluşturuyoruz
        new_profile_info = ProfilBilgileri(
            kullanici_id=user_id,
            adres=updated_profile.adres,
            dogum_tarihi=updated_profile.dogum_tarihi,
            photo_url=updated_profile.photo_url
        )
        db.add(new_profile_info)

    db.commit()
    return {"message": "Profil başarıyla güncellendi!"}
# Hesap silme
@app.delete("/delete_account/{user_id}")
def delete_account(user_id: int, db: Session = Depends(get_db)):
    profile = db.query(Kullanici).filter(Kullanici.id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı!")
    
    # Kullanıcıya ait başvuruları ve diğer ilişkili verileri sil
    db.query(Basvuru).filter(Basvuru.kullanici_id == user_id).delete()
    db.query(ProfilBilgileri).filter(ProfilBilgileri.kullanici_id == user_id).delete()
    db.query(Kullanici).filter(Kullanici.id == user_id).delete()

    db.commit()
    return {"message": "Hesap başarıyla silindi!"}
# Kullanıcı Puanlama (POST /rate_user)
class RatingRequest(BaseModel):
    from_user_id: int
    to_user_id: int
    job_id: int
    rating: int
    yorum: str

@app.post("/rate_user")
def rate_user(rating_data: RatingRequest, db: Session = Depends(get_db)):
    if rating_data.rating < 1 or rating_data.rating > 5:
        raise HTTPException(status_code=400, detail="Geçersiz puan! Puan 1 ile 5 arasında olmalıdır.")

    # İş ilanı ve kullanıcı var mı kontrol et
    job = db.query(IsIlani).filter(IsIlani.id == rating_data.job_id).first()
    to_user = db.query(Kullanici).filter(Kullanici.id == rating_data.to_user_id).first()
    if not job or not to_user:
        raise HTTPException(status_code=404, detail="İş ilanı veya kullanıcı bulunamadı!")

    # Puanlama işlemini yap
    yeni_rating = Rating(
        from_user_id=rating_data.from_user_id, 
        to_user_id=rating_data.to_user_id, 
        job_id=rating_data.job_id,
        rating=rating_data.rating,
        yorum=rating_data.yorum
    )
    
    db.add(yeni_rating)
    db.commit()
    return {"message": "Kullanıcı başarıyla puanlandı!"}
# Kullanıcı Puanını Hesaplama
def calculate_user_rating(user_id: int, db: Session = Depends(get_db)):
    ratings = db.query(Rating).filter(Rating.to_user_id == user_id).all()
    if not ratings:
        return 0  # Puan yoksa 0 döndür
    
    total_rating = sum([rating.rating for rating in ratings])
    return total_rating / len(ratings)
# Kullanıcının Geçmiş İş İlanları
def get_user_past_jobs(user_id: int, db: Session = Depends(get_db)):
    # İş ilanı başvurularının listesini döndürüyoruz
    past_jobs = db.query(Basvuru, IsIlani).join(IsIlani).filter(Basvuru.kullanici_id == user_id).all()
    return [{"job_title": job.IsIlani.baslik, "status": job.Basvuru.durum} for job in past_jobs]

# Profil Fotoğrafı Yükleme (POST /upload_photo)

@app.post("/upload_photo/{user_id}")
async def upload_profile_picture(user_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    profile_info = db.query(ProfilBilgileri).filter(ProfilBilgileri.kullanici_id == user_id).first()
    
    if not profile_info:
        raise HTTPException(status_code=404, detail="Profil bilgileri bulunamadı!")

    # Fotoğrafın geçerli bir formatta olup olmadığını kontrol etme
    allowed_extensions = ["jpg", "jpeg", "png"]
    file_extension = file.filename.split(".")[-1].lower()

    if file_extension not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Geçersiz dosya formatı. Yalnızca .jpg, .jpeg, .png dosyalarına izin verilir.")
    
    # Firebase Storage'a fotoğraf yükleme
    storage = firebase.storage()

    # Fotoğraf dosyasını geçici olarak kaydediyoruz
    temp_file = f"temp_{user_id}_profile.jpg"
    with open(temp_file, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        # Firebase Storage'a yükleme
        storage.child(f'profile_pictures/{user_id}_profile.jpg').put(temp_file)

        # Fotoğrafın URL'sini almak
        photo_url = storage.child(f'profile_pictures/{user_id}_profile.jpg').get_url(None)

        # Profil fotoğrafı mevcutsa, güncelleme işlemi yapıyoruz
        profile_info.photo_url = photo_url
        db.commit()  # Veritabanında güncelleme yapıyoruz

        # Geçici dosyayı sil
        os.remove(temp_file)

        return {"message": "Profil fotoğrafı başarıyla yüklendi!", "photo_url": photo_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fotoğraf yüklenirken hata oluştu: {str(e)}")






