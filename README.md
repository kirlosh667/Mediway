# 🏥 Mediway

Mediway is a full-stack healthcare management system built using **Django (Backend)** and **Flutter (Frontend)**.  
The system helps manage patients, doctors, appointments, and medical records efficiently through a secure REST API and a cross-platform mobile application.

---

## 🚀 Features

- 👨‍⚕️ Doctor & Patient Authentication
- 📅 Appointment Booking System
- 📝 Medical Records Management
- 🏥 Admin Dashboard
- 🔐 Secure REST API with Django REST Framework
- 📱 Cross-platform Flutter App (Android / iOS)
- 📊 Clean and User-Friendly Interface

---

## 🛠️ Tech Stack

### 🔹 Backend
- Python
- Django
- Django REST Framework
- SQLite / PostgreSQL
- JWT Authentication

### 🔹 Frontend
- Flutter
- Dart
- REST API Integration

---

## 📂 Project Structure

```
Mediway/
│
├── backend/              # Django backend (API)
│   ├── manage.py
│   ├── mediway/          # Main Django project
│   └── apps/             # Django apps
│
├── frontend/
│   └── mediway_app/      # Flutter application
│
└── README.md
```

---

## ⚙️ Installation & Setup

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/kirlosh667/Mediway.git
cd Mediway
```

---

# 🐍 Backend Setup (Django)

### 2️⃣ Create Virtual Environment

```bash
cd backend
python -m venv venv
```

Activate virtual environment:

**Windows**
```bash
venv\Scripts\activate
```

**Mac/Linux**
```bash
source venv/bin/activate
```

### 3️⃣ Install Dependencies

```bash
pip install -r requirements.txt
```

### 4️⃣ Run Migrations

```bash
python manage.py migrate
```

### 5️⃣ Run Development Server

```bash
python manage.py runserver
```

Backend will run on:
```
http://127.0.0.1:8000/
```

---

# 📱 Frontend Setup (Flutter)

### 6️⃣ Navigate to Flutter App

```bash
cd frontend/mediway_app
```

### 7️⃣ Install Dependencies

```bash
flutter pub get
```

### 8️⃣ Run the Application

```bash
flutter run
```

Make sure:
- Flutter SDK is installed
- Emulator or physical device is connected

---

## 🔑 Environment Variables

Create a `.env` file inside the `backend` directory if needed:

```
SECRET_KEY=your_secret_key
DEBUG=True
DATABASE_URL=your_database_url
```

---

## 🚀 Deployment

### Backend Deployment Options
- Render
- Railway
- Heroku
- AWS

### Build Flutter APK

```bash
flutter build apk
```

---

## 🔮 Future Improvements

- 💳 Online Payment Integration
- 📹 Video Consultation Feature
- 🔔 Push Notifications
- 📈 Advanced Analytics Dashboard
- ☁️ Cloud Deployment Optimization

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository  
2. Create a feature branch  
3. Commit your changes  
4. Push and open a Pull Request  

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

**Kirlosh**  
GitHub: https://github.com/kirlosh667

---

⭐ If you like this project, please give it a star!
