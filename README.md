# Flutter Expense Tracking Semester Project

**Live demo:** Not deployed yet

## What it does
A comprehensive mobile and web application designed to help users manage their personal finances with ease. It allows users to track income and expenses, visualize spending patterns through interactive charts, and securely store data in the cloud using Firebase.

## Tech stack
- **Frontend:** Flutter (Dart)
- **Backend/Database:** Cloud Firestore
- **Authentication:** Firebase Auth
- **State Management:** Provider
- **Data Visualization:** fl_chart & syncfusion_flutter_charts
- **UI Components:** Shimmer, Google Fonts (Inter), Font Awesome Icons

## Key features
- **Real-time CRUD Operations:** Create, read, update, and delete transactions with instant synchronization across devices via Firestore.
- **Dynamic Analytics Dashboard:** Visualizes financial data using Pie and Line charts to help users identify spending trends and categories.
- **Secure User Authentication:** Full login and registration flow to keep personal financial data private and persistent.
- **Modern UI/UX Design:** Features a polished, user-friendly interface with smooth transitions, custom themes, and shimmer loading effects.
- **Cross-Platform Support:** Built to run seamlessly on both mobile (Android/iOS) and Web platforms.

## Getting started

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/[your-username]/expense-tracker.git
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Configuration:**
    *   Place your `google-services.json` in `android/app/`.
    *   Place your `GoogleService-Info.plist` in `ios/Runner/`.
    *   Ensure a valid `firebase_options.dart` is present in the `lib/` folder if running on Web.
4.  **Run the Application:**
    ```bash
    flutter run
    ```

## Why I built this
This project was originally developed for a Mobile App Development course at university, but I chose to push the boundaries of the assignment by implementing a full-scale production-ready architecture with Firebase integration and high-end UI/UX features to create a truly ambitious financial tool.
