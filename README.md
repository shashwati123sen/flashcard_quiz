markdown
# 🧠 Flutter Quiz App

A fully-featured quiz application built with Flutter and Firebase. This app supports two user roles:

- 👤 **Users** – Can browse categories, attempt quizzes, view results, add flashcards, delete flashcards.
- 🛠️ **Admins** – Can manage categories, quizzes, and quiz questions.

---

## ✅ Features

### User Features:
- Browse and select quiz categories
- Attempt timed quizzes with real-time progress tracking
- View detailed quiz results upon completion
- Create, view, and delete personal flashcards for effective study and revision

### Admin Features:
- Add, edit, and delete quiz categories
- Add, edit, and delete quizzes within categories
- Add, edit, and delete quiz questions to maintain content quality


## 📁 Folder Structure

```

lib/
├── main.dart
├── firebase\_options.dart
│
├── model/
│   ├── category.dart
│   ├── quiz.dart
│   └── question.dart
│
├── theme/
│   └── theme.dart
│
└── view/
├── admin/
│   ├── admin\_home\_screen.dart
│   ├── manage\_category\_screen.dart
│   ├── manage\_quiz\_screen.dart
│   ├── add\_quiz\_screen.dart
│   ├── edit\_quiz\_screen.dart
│   └── add\_category\_screen.dart
│
└── user/
├── home\_screen.dart
├── category\_screen.dart
├── quiz\_play\_screen.dart
└── quiz\_result\_screen.dart

````

---

## 🚀 Getting Started

### 1. ✅ Prerequisites
- Flutter SDK installed
- Firebase project created
- `firebase_options.dart` configured (already included)
- Emulator or physical device ready

### 2. 🔧 Install Dependencies

```bash
flutter pub get
````

---

## 🏃 Run the App

### 🔐 As Admin

To run the app starting from the **Admin Home Screen**, update your `main.dart` like this:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashCard_Quiz",
      theme: AppTheme.theme,
      home: AdminHomeScreen(), // Change to HomeScreen() for User 
    );
  }
}

```

### 👤 As User

To run the app starting from the **User Home Screen**, update your `main.dart` like this:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashCard_Quiz",
      theme: AppTheme.theme,
      home: HomeScreen(), // Change to AdminHomeScreen() for admin
    );
  }
}

```

---

## 🔐 Firebase Setup (Optional)

Ensure your Firebase project is linked properly. If not done already:

```bash
flutterfire configure
```

---

## 🧪 Testing

To run on an emulator or connected device:

```bash
flutter run
```

---

## 🙌 Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

```

Let me know if you also want a badge section (for Flutter version, build status, etc.) or GitHub actions for CI/CD integration!
```
