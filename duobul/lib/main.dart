import 'package:duobul/ThemeData/themedata.dart';
import 'package:flutter/material.dart';
import 'screens/signup.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: duoBulDarkPurpleTheme,
      home: const SignUpScreen(),
    );
  }
}
