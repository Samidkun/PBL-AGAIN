# 💅 Luxe Nail — Laravel + Flutter Fullstack Project

Sistem **Luxe Nail Reservation** terdiri dari:

- **WEB Admin Panel** → Laravel (Backend + Dashboard Admin)  
- **Mobile Client App** → Flutter (Aplikasi User)

---

## 🧩 Project Structure

```
PBL-AGAIN/
├── WEB/                # Laravel Backend (Admin & REST API)
│   └── luxe-nail/
│       ├── app/
│       ├── bootstrap/
│       ├── config/
│       ├── database/
│       ├── public/
│       ├── resources/
│       ├── routes/
│       ├── storage/
│       ├── .env
│       └── composer.json
│
├── MOBILE/             # Flutter Frontend (User App)
│   └── luxe_nail/
│       ├── lib/
│       ├── assets/
│       ├── android/
│       ├── ios/
│       ├── pubspec.yaml
│       └── build/
│
└── .gitignore
```

---

## ⚙️ WEB SETUP — Laravel (Backend + API)

### **Requirements**
- PHP ≥ 8.1  
- Composer  
- MySQL / MariaDB  
- Node.js (Vite)

### **Setup Steps**
```bash
cd WEB/luxe-nail

composer install
npm install && npm run dev

cp .env.example .env

php artisan key:generate

php artisan migrate --seed

php artisan serve
```

Laravel berjalan di:  
**http://127.0.0.1:8000**

---

## 📱 MOBILE SETUP — Flutter (Client App)

### **Setup**
```bash
cd MOBILE/luxe_nail
flutter pub get
flutter run
```

---

# 🌍 API CONNECTION – NGROK SETUP (WAJIB)

## 1. Download Ngrok
https://ngrok.com/download

---

## 2. Tambahkan Authtoken
```
ngrok config add-authtoken TOKEN_KAMU
```

---

## 3. Jalankan Laravel API
```
php artisan serve
```

---

## 4. Jalankan Ngrok tanpa Warning Page
```
ngrok http 8000 --user-agent="mobile"
```

Gunakan URL ngrok yang muncul sebagai **BASE_URL API**.

---

## 5. Update Flutter `.env`
```
BASE_URL=https://your-ngrok-id.ngrok-free.app
```

---

## 6. Contoh Fetch API di Flutter

```dart
if (response.body.startsWith("<")) {
  throw Exception("Server returned HTML, not JSON. Cek ngrok.");
}

final data = jsonDecode(response.body);
```

---

## 💡 Tips untuk Tim

- Ngrok URL **berubah setiap restart**
- Semua device bisa pakai URL yang sama
- Gunakan `--user-agent="mobile"`

---

