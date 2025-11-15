# 💅 Luxe Nail — Laravel + Flutter Fullstack Project

This repository contains **both the Web Admin Panel (Laravel)** and the **Mobile Client App (Flutter)** for the **Luxe Nail Reservation System** — a modern platform for managing nail art reservations, designs, and customer queues.

---

## 🧩 Project Structure

PBL-AGAIN/
├── WEB/ # Laravel Backend (Admin & API)
│ └── luxe-nail/
│ ├── app/
│ ├── bootstrap/
│ ├── config/
│ ├── database/
│ ├── public/
│ ├── resources/
│ ├── routes/
│ ├── storage/
│ ├── .env
│ └── composer.json
│
├── MOBILE/ # Flutter Frontend (User App)
│ └── luxe_nail/
│ ├── lib/
│ ├── assets/
│ ├── android/
│ ├── ios/
│ ├── pubspec.yaml
│ └── build/
│
└── .gitignore


---

## ⚙️ Laravel (WEB) Setup

**Requirements:**
- PHP ≥ 8.1
- Composer
- MySQL or MariaDB
- Node.js (for Vite assets)

**Steps:**
```bash
cd WEB/luxe-nail

# Install dependencies
composer install
npm install && npm run dev

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Setup database (adjust credentials in .env)
php artisan migrate --seed

# Serve the app
php artisan serve

Laravel app will run at:
👉 http://127.0.0.1:8000

📱 Flutter (MOBILE) Setup

Requirements:

Flutter SDK (3.x+)

Android Studio or VS Code

Emulator or physical device

cd MOBILE/luxe_nail

# Get all dependencies
flutter pub get

# Run the app
flutter run
You can connect the mobile app to Laravel’s API via the base URL (e.g. http://127.0.0.1:8000/api)

