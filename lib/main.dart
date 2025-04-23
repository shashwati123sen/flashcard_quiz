import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:quiz_project/view/admin/admin_home_screen.dart";
import "package:quiz_project/theme/theme.dart";

import "firebase_options.dart";




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlashCard_Quiz",
        theme: AppTheme.theme,
      home: AdminHomeScreen()
    );
  }
}

