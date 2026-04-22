# Her Cycle - Menstrual Period Tracker App

A comprehensive Flutter application designed to help women track their menstrual cycles, get health insights, and receive timely notifications about periods, ovulation, and fertile days.

## Features

- 📱 **Period Tracking**: Track your menstrual cycle with ease
- 📊 **Cycle Insights**: Get detailed statistics and patterns about your cycles
- 🗓️ **Calendar View**: Visual representation of your cycle phases
- 🔔 **Smart Notifications**: Get reminders for periods, ovulation, and fertile days
- 📝 **Symptom Logging**: Record and track symptoms throughout your cycle
- 🌐 **Multi-Language Support**: Available in 9 languages (English, Arabic, French, Spanish, Portuguese, Swahili, Hindi, Chinese, Amharic)
- 🌙 **Dark Mode**: Comfortable viewing in light and dark modes
- 🔒 **Privacy First**: Your data is stored securely on your device and synced with Firebase only with your consent
- 💬 **SMS Notifications**: Optional SMS reminders for important dates
- 📈 **Predictive Analysis**: AI-powered predictions based on your cycle history

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Firebase (Authentication, Firestore, Cloud Messaging)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: Firebase Cloud Messaging + Local Notifications
- **SMS**: Twilio
- **UI Components**: Material Design 3, Custom Widgets

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Android Studio or Xcode
- Firebase CLI

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd her_cycle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Download the Firebase configuration files
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

4. **Update firebase_options.dart**
   - Replace the placeholder Firebase options with your actual configuration

5. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                # App entry point
├── app.dart                 # App configuration
├── core/
│   ├── constants/          # App constants
│   ├── themes/             # Light and dark themes
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── features/               # Feature modules
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── calendar/
│   ├── logging/
│   ├── insights/
│   ├── notifications/
│   └── profile/
├── models/                 # Data models
├── providers/              # State management
├── services/               # Business logic
└── l10n/                   # Localization files
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_PHONE_NUMBER=your_twilio_number
```

## Usage

### Getting Started

1. Launch the app - you'll see the onboarding screens
2. Create an account or sign in with Google
3. Enter your last period date and cycle length
4. Start tracking!

### Features Overview

- **Home Screen**: Quick overview of your current cycle and upcoming dates
- **Calendar**: Visual calendar with period/fertile/ovulation days marked
- **Log Symptoms**: Record how you're feeling and physical symptoms
- **Insights**: View statistics and patterns in your cycles
- **Settings**: Configure notifications and preferences

## API Documentation

### Available Endpoints (Firebase)

- User Authentication
- Cycle Data CRUD operations
- Symptom Logging
- Notification Scheduling
- User Profile Management

## Development

### Running Tests

```bash
flutter test
```

### Building for Release

**Android:**
```bash
flutter build apk
# or
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@hercycle.app or open an issue on GitHub.

## Roadmap

- [ ] Apple Health integration
- [ ] Wearable device integration
- [ ] Community features
- [ ] Advanced AI predictions
- [ ] Telehealth consultation integration
- [ ] Pharmaceutical integration

## Acknowledgments

- Flutter community
- Firebase team
- Design inspiration from modern health apps
- Contributors and testers

## Disclaimer

This app is designed for informational purposes only and should not be used as a medical diagnosis tool. Always consult with a healthcare provider for medical concerns.
