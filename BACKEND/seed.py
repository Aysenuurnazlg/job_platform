from BACKEND.mainn import SessionLocal, IsIlani

def seed_jobs():
    db = SessionLocal()

    jobs = [
        # Günlük Yaşam Destek Görevleri
        {"baslik": "Market ve Alışveriş Yardımı", "aciklama": "Kullanıcının belirlediği marketten veya pazardan alışveriş yapıp kullanıcıya teslim etmek."},
        {"baslik": "Eczane & Reçete Teslimatı", "aciklama": "İlaçlarını almakta zorlanan kişilere eczaneden ilaç getirerek yardımcı olmak."},
        {"baslik": "Fatura Ödeme Yardımı", "aciklama": "Elektrik, su, doğalgaz gibi faturaların yatırılmasında destek olmak."},
        {"baslik": "Ev Temizliği ve Düzeni", "aciklama": "Hafif temizlik, eşyaların düzenlenmesi veya küçük ev işleri yapmak."},
        {"baslik": "Kıyafet Yardımı & Çamaşırhane", "aciklama": "Kuru temizlemeye veya çamaşırhaneye kıyafet götürüp getirmek."},
        {"baslik": "Evcil Hayvan Bakımı", "aciklama": "Köpek gezdirme, kedi kumu temizliği veya evcil hayvan alışverişi yapma."},

        # Sağlık ve Kişisel Destek Görevleri
        {"baslik": "Hastane Randevu Takibi", "aciklama": "Yaşlı ve engelli bireyler için hastane veya doktor randevularının planlanması."},
        {"baslik": "Refakatçi Hizmeti", "aciklama": "Hastaneye, doktora veya başka bir yere gitmesi gereken kişiye eşlik etmek."},
        {"baslik": "Fiziksel Destek", "aciklama": "Tekerlekli sandalye kullanımı konusunda yardım etmek, dışarı çıkarken destek sağlamak."},
        {"baslik": "Egzersiz ve Yürüyüş Arkadaşı", "aciklama": "Yaşlıların veya fiziksel engelli bireylerin açık havada yürüyüş yapmalarına yardımcı olmak."},
    ]

    for job_data in jobs:
        job = IsIlani(baslik=job_data["baslik"], aciklama=job_data["aciklama"])
        db.add(job)

    db.commit()
    db.close()
    print("İş ilanları başarıyla eklendi.")

if __name__ == "__main__":
    seed_jobs()
