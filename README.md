# Kelompok 3 SI2024E

Fauzan Zaki (24051214144)
M. Zulfikar Wahyu P. (24051214146)
Ihza Budi Cendhika (24051214163)
Neilsen Iyanaka (24051214169)
Arum Fatimah A. (24051214175)

# ✈️ TraveLokuy (Clone Traveloka MVP)

Aplikasi pemesanan tiket pesawat dan reservasi hotel lengkap dengan backend REST API (Express + MySQL) dan frontend mobile/web (Flutter).

---

## 🚀 Fitur Utama

1. **Autentikasi (JWT & Bcrypt)**:
   - Register akun baru & Login
   - Akun Demo siap pakai: `budi@travelokuy.com` (password: `password123`)
   - Profil pengguna, ubah nama/telepon, dan statistik pemesanan

2. **Beranda & Promo Khas Traveloka**:
   - Header biru ikonik (#0194F3 & #0064D2) dengan salam pengguna
   - Menu pintas utama: **Tiket Pesawat** & **Hotel & Penginapan**
   - Slider promo dinamis (*EPIC Sale 2026*, *Staycation Hemat*, *Diskon Maskapai*)
   - Destinasi populer favorit di Indonesia (Bali, Yogyakarta, Jakarta, Surabaya, Bandung)

3. **Pemesanan Tiket Pesawat**:
   - Pencarian berdasarkan kota/bandara asal, tujuan, tanggal berangkat, dan jumlah penumpang
   - Autocomplete bandara populer (CGK, SUB, DPS, YIA, KNO, UPG, BDO, HLP, BPN)
   - Filter maskapai (Garuda Indonesia, Batik Air, Citilink, Lion Air, Super Air Jet, AirAsia)
   - Urutkan berdasarkan harga termurah/tertinggi, jam keberangkatan, dan durasi
   - Form data penumpang dinamis (Tn/Ny/Nn, Nama Lengkap, Nomor KTP/Paspor)
   - **Transaksi Database ACID**: Penguncian baris (`FOR UPDATE`) & pengurangan kursi secara realtime

3. **Pemesanan Tiket Kereta Api (KAI & Kereta Cepat Whoosh)**:
   - Pencarian stasiun asal dan tujuan dengan tombol swap stasiun
   - Dukungan stasiun KAI (Gambir, Pasar Senen, Bandung, Yogyakarta, Surabaya Gubeng, Solo Balapan, Semarang Tawang) dan Whoosh (Stasiun KCIC Halim & Tegalluar)
   - Badge khusus Whoosh (Merah Crimson) dan KAI (Oranye/Biru)
   - Filter kelas kereta: Kereta Cepat (Whoosh), Eksekutif, Bisnis, Ekonomi
   - Pilihan rute populer cepat: Jakarta - Bandung (Whoosh 45 Menit), Jakarta - Yogyakarta (Taksaka), Jakarta - Surabaya (Argo Bromo Anggrek)
   - Alur pemesanan lengkap: Pilih stasiun -> Hasil pencarian -> Form identitas NIK/KTP penumpang -> Simulasi pembayaran -> E-Tiket Boarding Pass dengan QR Code khusus stasiun

4. **Layanan Transportasi & Wisata Lainnya (Lengkap Sesuai Traveloka Asli)**:
   - **Bus & Travel / Shuttle**: Pilihan armada ternama (Rosalia Indah, Sinar Jaya, DAMRI), filter kelas sleeper & executive, dan fitur pemilihan nomor kursi bus interaktif.
   - **TraveLokuy Xperience**: Tiket atraksi wisata & taman hiburan (Dufan Ancol, Taman Safari, Waterbom Bali, Candi Borobudur) dengan konfirmasi instan.
   - **Rental Mobil**: Pilihan sewa mobil lepas kunci atau dengan sopir (Avanza, Innova Reborn, Fortuner, HiAce) lengkap dengan durasi hari dan kalkulasi tarif otomatis.
   - **Antar Jemput Bandara**: Layanan penjemputan bandara resmi (CGK, HLP, DPS, SUB, YIA) dengan opsi Private Car, Premium Bluebird Taxi, dan DAMRI Airport Shuttle.
   - **Asuransi Perjalanan (TraveLokuy Safe)**: Perbandingan polis perlindungan (Basic, Gold, Platinum) dengan pertanggungan s/d Rp 500.000.000 terdaftar OJK.

5. **Pemesanan Hotel & Resort**:
   - Pencarian kota tujuan, tanggal check-in & check-out, serta jumlah tamu & kamar
   - Hasil pencarian menampilkan bintang hotel, foto beresolusi tinggi, fasilitas, ulasan, dan harga mulai dari
   - Detail hotel lengkap dengan galeri foto, fasilitas (WiFi, Kolam Renang, Spa, Restoran), dan ulasan tamu
   - Pengecekan ketersediaan tipe kamar secara dinamis berdasarkan rentang tanggal
   - Fitur wishlist / simpan hotel favorit
   - Form penulisan ulasan dan rating hotel 1–5 bintang

6. **Simulasi Pembayaran (Payment Gateway Simulation)**:
   - Pilihan metode: BCA Virtual Account, Mandiri VA, BRI VA, GoPay, OVO, Kartu Kredit
   - Countdown timer kedaluwarsa pesanan (1 jam hitung mundur)
   - Tombol sekali klik "Bayar Sekarang" yang langsung mengubah status transaksi menjadi **PAID**

7. **Pesanan Saya & E-Tiket / Voucher Resmi**:
   - Tab status: Semua, Menunggu Bayar (PENDING), Selesai/Aktif (PAID), Batal/Expired
   - Dukungan multi-layanan: Tiket Pesawat, Voucher Hotel, dan Tiket Kereta Api
   - Pembatalan pesanan yang otomatis mengembalikan kursi kereta/pesawat / kamar
   - Halaman E-Tiket & Voucher bergaya boarding pass dengan **Kode Booking Acak (PNR)** dan **QR Code aktif** (`qr_flutter`) untuk proses boarding/check-in

8. **Pusat Notifikasi Interaktif (Notification Center)**:
   - Ikon lonceng di AppBar beranda dengan badge jumlah notifikasi belum dibaca (*unread badge*)
   - Tab kategori: **Semua**, **Pesanan & Transaksi**, **Promo & Diskon**, dan **Info Perjalanan**
   - Riwayat notifikasi aktif: Status e-tiket Whoosh & Pesawat, EPIC Sale diskon promo, status pembayaran berhasil, voucher wahana Xperience, info armada bus baru, dan polis asuransi
   - Tombol sekali klik "Tandai Dibaca" (*Mark all as read*)
   - Modal detail interaktif untuk membaca pesan lengkap notifikasi


---

## 🛠️ Tech Stack & Arsitektur

- **Backend**:
  - Node.js & Express
  - `mysql2/promise` (Connection pool & transaksi `beginTransaction()`, `commit()`, `rollback()`)
  - JSON Web Token (`jsonwebtoken`) & `bcryptjs`
  - CORS & Dotenv
- **Database**:
  - MySQL / MariaDB (`traveloka_clone`)
  - Schema terdefinisi di [schema.sql](file:///d:/DataSkills/New%20folder/Traveloka/backend/schema.sql)
- **Frontend**:
  - Flutter (Dart)
  - `provider` (State management)
  - `http` (REST API Client)
  - `intl` (Format Rupiah & Tanggal Bahasa Indonesia)
  - `qr_flutter` (QR Code Generator)
  - `google_fonts` (Plus Jakarta Sans typography)
  - `shared_preferences` (Penyimpanan token JWT lokal)

---

## 🗄️ Struktur Proyek

```
Traveloka/
├── MVP-TraveLoka.md            # Panduan & spesifikasi MVP
├── README.md                   # Dokumentasi proyek
├── backend/
│   ├── .env                    # Konfigurasi port, DB, dan JWT
│   ├── package.json            # Dependencies backend
│   ├── schema.sql              # Skema tabel MySQL lengkap
│   └── src/
│       ├── server.js           # Entry point Express API
│       ├── config/db.js        # Konfigurasi MySQL connection pool
│       ├── middleware/auth.js  # JWT Middleware & protection
│       ├── controllers/        # Logika bisnis (auth, flights, hotels, bookings, review, wishlist)
│       ├── routes/             # REST API endpoint routes
│       └── seeds/seed.js       # Seeder otomatis 560+ penerbangan, hotel, & user demo
└── frontend/
    ├── pubspec.yaml            # Dependencies Flutter
    └── lib/
        ├── main.dart           # Entry point Flutter
        ├── constants/          # Warna Traveloka & API base URL
        ├── models/             # Data models (Flight, Hotel, Booking, User, dll)
        ├── providers/          # State management (Auth, Flight, Hotel, Booking)
        ├── services/           # ApiService HTTP client
        ├── widgets/            # Reusable components (FlightCard, HotelCard, BannerSlider, CustomButton)
        └── screens/            # 14 Layar lengkap sesuai MVP
```

---

## 💻 Cara Menjalankan

### Cara Paling Cepat (1-Klik):
Cukup klik ganda (double-click) file **[run_app.bat](file:///d:/DataSkills/New%20folder/Traveloka/run_app.bat)** di folder utama. File ini otomatis akan membuka MySQL (3307), Server Backend (5000), dan Flutter Chrome secara berurutan.

---

### Cara Manual (Melalui Terminal):

#### 1. Database & Backend

1. Buka terminal pada folder `backend/`:
   ```bash
   cd backend
   ```
2. Pastikan database MySQL aktif di port 3307:
   ```bash
   npm run db:start
   ```
3. Jalankan seeder database (membuat database `traveloka_clone`, tabel, dan mengisinya dengan data):
   ```bash
   npm run seed
   ```
4. Jalankan server API:
   ```bash
   npm start
   ```
   Server akan aktif di: `http://localhost:5000`

### 2. Frontend Flutter

1. Buka terminal pada folder `frontend/`:
   ```bash
   cd frontend
   ```
2. Jalankan di browser Chrome:
   ```bash
   flutter run -d chrome
   ```
   Atau untuk aplikasi desktop Windows:
   ```bash
   flutter run -d windows
   ```

---

## 👤 Akun Pengujian Demo

- **Email**: `budi@travelokuy.com`
- **Password**: `password123`
*(Tersedia tombol satu-klik otomatis pada form login)*
