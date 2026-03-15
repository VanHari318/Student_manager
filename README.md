# Student Manager

A Flutter project to manage students. It follows the architecture from Day 1-4, utilizing Provider for state management and Firebase Firestore for database.

## 🚀 Getting Started for Collaborators

If you pull this repository to continue working on other screens, please follow these steps:

1. **Install Dependencies:**
   Run the following command to fetch all Dart packages:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   By default, the repository contains a **stub** `firebase_options.dart` file to prevent compile errors. To connect the app to your own Firebase project (or the team's project), you **must** run FlutterFire CLI before running the app.
   
   Ensure you have Firebase CLI and FlutterFire CLI installed and logged in, then run:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project and the platforms you want to support. This will overwrite `lib/firebase_options.dart` with your real config.

3. **Run the Application:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/models/`: Contains data models (`Student`, `Course`).
- `lib/services/`: Contains Firebase and API data services.
- `lib/providers/`: State management code.
- `lib/screens/`: UI screens (`SplashScreen`, `HomeScreen`, etc.). Tất cả màn hình có AppBar "TH5 - Nhóm 11".

---
*Created for Student Management App*
