# CureBit: Your Personal Health Record App

**CureBit** is a sleek and user-friendly medical document and health management app built using **Flutter**. It allows users to securely store, view, and manage medical records, book appointments, chat with assistants, and stay on top of their healthcare.

## 🚀 Features

* 📁 **Medical Document Storage**
  Upload and access prescriptions, reports, and other health documents.

* 💬 **Chat Assistant**
  Ask health-related queries with an integrated chat assistant.

* ⏰ **Medicine Reminders**
  Set reminders for your daily medications.

* 📅 **Appointment Booking**
  Book appointments and manage upcoming schedules.

* 👤 **User Profile & Settings**
  Edit profile, health info, and preferences.

* 🏠 **Minimal Home Dashboard**
  Clean, intuitive home screen for quick access to core features.

## 📱 Screenshots




## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (or your API if integrated)
* **State Management:** Riverpod 
* **Authentication:** Firebase Auth / OTP-based login (if integrated)
* **Database:** Firestore / SQLite (depending on implementation)

---

## 📂 Folder Structure

```
CureBit/
├── lib/
│   ├── common/            # Reusable widgets
│   ├── features/          # All app features
│   │    ├── auth/         # All authentication screens (login, sign up, forgot password, etc.)   
│   │    ├── doctor/       # All doctor side screens (chat, chat bot, schedule, etc.)   
│   │    ├── patient/      # All patient side screens (chat, chat bot, medical records, etc.)   
│   ├── services/          # All the repositories, APIs and models   
│   ├── utils/             # All utility files (Router files, providers, etc.)
│   └── main.dart          # Entry point
│
├── assets/                # Fonts, images, icons
├── pubspec.yaml           # Project dependencies
└── README.md
```

---

## 📦 Installation

1. **Clone the repository**

```bash
git clone https://github.com/nidhisingh5958/CureBit.git
cd CureBit
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

> Make sure a simulator/emulator or device is connected.

---

## ✅ To-Do / Upcoming Features

* [ ] Health analytics and insights
* [ ] Cloud sync and multi-device support
* [ ] Doctor directory and health service listings
* [ ] Secure document encryption
* [ ] Multi-language support

---

## 🧑‍💻 Author

**Nidhi Singh**
[GitHub Profile](https://github.com/nidhisingh5958)

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

<!-- <a href="https://www.flaticon.com/free-icons/login" title="icons"></a> -->
