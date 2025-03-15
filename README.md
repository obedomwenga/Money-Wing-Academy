# Money Wing Academy

A financial literacy mobile application designed to help underserved communities, immigrants, and young adults manage their finances effectively.

## Getting Started with Project IDX

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/money-wing-academy.git
   cd money-wing-academy
   ```

2. Set up Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Google Sign-in)
   - Enable Cloud Firestore
   - Enable Storage
   - Add a Flutter application to your Firebase project
   - Download the Firebase configuration files:
     - For Android: `google-services.json` → place in `android/app`
     - For iOS: `GoogleService-Info.plist` → place in `ios/Runner`
   - Create `lib/core/config/firebase_options.dart` with your Firebase configuration

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate necessary files:
   ```bash
   dart run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Features

- 🔐 Secure Authentication
  - Email & Password login
  - Google Sign-in
  - Password recovery

- 💰 Budget Tracking
  - Set monthly budgets by category
  - Visual progress indicators
  - Spending alerts

- 📊 Expense Management
  - Easy expense entry
  - Category-based organization
  - Spending analytics

- 🎯 Financial Goals
  - Set and track financial goals
  - Progress monitoring
  - Estimated completion dates

## Project Structure

```
lib/
  ├── core/
  │   ├── config/
  │   ├── theme/
  │   └── utils/
  ├── features/
  │   ├── auth/
  │   ├── budget/
  │   ├── expenses/
  │   ├── goals/
  │   └── home/
  └── shared/
      ├── models/
      ├── widgets/
      └── services/
```

## Development Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project
- IDE with Flutter support (VS Code, Android Studio, or Project IDX)

### Running in Project IDX
1. Open the project in Project IDX
2. Install dependencies: `flutter pub get`
3. Generate code: `dart run build_runner build`
4. Configure Firebase
5. Run the app: `flutter run`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who help improve the app 