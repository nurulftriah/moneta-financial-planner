# Moneta - Financial Tracker & Manager

Moneta is a comprehensive personal finance tracking application built with Flutter. It helps users manage their income, expenses, budgets, and savings with a beautiful, modern glassmorphism interface.

## Key Features

*   **Expense & Income Tracking**: Easily record daily transactions with categories, dates, and descriptions.
*   **Recurring Transactions / Subscriptions**: Set up automated transactions for regular bills or salary.
    *   Supports Daily, Weekly, Monthly, and Yearly frequencies.
    *   Automatically processes due transactions on app launch.
*   **AI Receipt Scanner**: Scan receipts using your camera or pick from the gallery.
    *   **OCR Technology**: Uses Google ML Kit (on-device) to extract text.
    *   **Smart Parsing**: Automatically detects the Total Amount, Date, and Merchant Name from the receipt.
*   **Budget Management**: Create monthly budgets for specific categories to keep your spending in check.
*   **Financial Analysis**: Visualize your spending habits with intuitive charts and reports.
*   **Calendar View**: Track your transactions day-by-day.
*   **Multi-Language Support**: Fully localized to English and Indonesian.
*   **Customizable Categories**: Add, edit, and reorganize your expense/income categories.
*   **Secure**: Built on Firebase (Auth & Firestore) for secure cloud data storage.

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your development machine:

1.  **Flutter SDK**: Version `2.12.0` or higher (Project uses Dart SDK `2.18.0` constraints).
2.  **Java Development Kit (JDK)**: JDK 11 or JDK 17 (Recommended for Android development).
3.  **Android Studio**: For Android development and emulator management.
4.  **Xcode** (macOS only): For iOS development.
5.  **CocoaPods** (macOS only): For managing iOS dependencies.

### Installation

1.  **Clone the Repository**
    

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Set Up Firebase**
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Add an **Android** app (package: `com.pam.moneta`) and download `google-services.json`. Place it in `android/app/`.
    *   Add an **iOS** app (bundle ID: `com.pam.moneta`) and download `GoogleService-Info.plist`. Place it in `ios/Runner/`.
    *   Enable **Authentication** (Email/Password, Google).
    *   Enable **Cloud Firestore** database.

4.  **Run the App**

    *   **Android**:
        ```bash
        flutter run
        ```

    *   **iOS**:
        ```bash
        cd ios
        pod install
        cd ..
        flutter run
        ```

---

## Development & Architecture

### Tech Stack
*   **Framework**: Flutter (Dart)
*   **Backend**: Firebase (Auth, Firestore)
*   **State Management**: Provider

### Key Libraries
*   `cloud_firestore`: Database interactions
*   `firebase_auth`: User authentication
*   `provider`: State management
*   `flutter_screenutil`: Responsive UI design
*   `google_mlkit_text_recognition`: OCR for receipt scanning
*   `image_picker`: Camera and Gallery access
*   `flutter_localizations`: Internationalization

---

## Features In-Depth

### 1. Recurring Transactions
Located under **Other -> Recurring Transactions**, this feature allows you to define expenses or incomes that happen repeatedly.
*   **Implementation**: A custom service checks for due transactions every time the app opens (`Home.dart`).
*   **Logic**: Calculating the next occurrence based on frequency (Daily, Weekly, Monthly, Yearly) and automatically generating a standard transaction record.

### 2. AI Receipt Scanner
Integrated into the **Add Transaction** screen (tap the Camera icon in the Amount card).
*   **How it works**:
    1.  User selects Camera or Gallery.
    2.  App processes the image using ML Kit.
    3.  Heuristic parsers scan the text for:
        *   **Amount**: Largest number with currency format.
        *   **Date**: Common date formats (dd/MM/yyyy, etc.).
        *   **Merchant**: Likely header text.
    4.  The form is auto-filled with the results.

### 3. Localization
The app detects the system language or can be manually switched in Settings.
*   Supported Languages: English (`en`), Indonesian (`id`).
*   To add a new language, update `lib/project/localization/lang/{code}.json`.

---

## Contributing

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## License

Distributed under the MIT License. See `LICENSE` for more information.
