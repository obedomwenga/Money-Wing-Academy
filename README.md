# Money Wing Academy

A financial literacy mobile application designed to help underserved communities, immigrants, and young adults manage their finances effectively.

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

- 📱 User-Friendly Interface
  - Intuitive navigation
  - Dark mode support
  - Responsive design

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/money_wing_academy.git
   cd money_wing_academy
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files:
     - Android: `google-services.json` to `android/app`
     - iOS: `GoogleService-Info.plist` to `ios/Runner`

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The project follows a clean architecture pattern with the following structure:

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