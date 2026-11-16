# BudgetBuddy – Student Budget Tracker

BudgetBuddy is a simple Flutter app that helps students manage allowance, record expenses, set a spending budget, and track savings. It works offline and stores information locally on the device with SharedPreferences.

## Features

- Dashboard with allowance, expenses, remaining balance, savings, and recent transactions
- Daily or weekly allowance entries with dates and allowance history
- Expense tracking with categories, dates, and delete confirmation
- Daily or weekly spending limit with progress and budget warnings
- Savings goal and amount-saved progress tracker
- Student profile name settings
- Philippine Peso formatting and responsive Material 3 layout
- Custom BudgetBuddy app icon and in-app logo
- Branded native splash screen for Android and iOS
- Local persistence; no Firebase, SQL, or online account required

The tracker starts with zero balances and no sample transactions. Add allowance entries to track your actual money, and edit an entry from Allowance History when you need to correct it.

## Requirements

- Flutter SDK (stable)
- Dart SDK included with Flutter
- Android Studio or an Android device/emulator for Android development
- Visual Studio Code with the Flutter and Dart extensions (recommended)

## Setup and run

1. Clone or download this repository.
2. From the project folder, install dependencies:

   ```sh
   flutter pub get
   ```

3. Check connected devices:

   ```sh
   flutter devices
   ```

4. Run the application:

   ```sh
   flutter run
   ```

To run the automated tests and static analysis:

```sh
flutter test
flutter analyze
```

To regenerate the Android and iOS app icons after changing the logo:

```sh
dart run flutter_launcher_icons
```

To regenerate the Android and iOS splash screen after changing the logo or
background color:

```sh
dart run flutter_native_splash:create
```

## Local data

The app stores allowance, expenses, budget settings, savings, and the profile name in the device's SharedPreferences. Data is not synchronized to another device. Uninstalling the app or clearing its storage may remove saved data.
