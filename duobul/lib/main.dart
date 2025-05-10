import 'package:duobul/ThemeData/themedata.dart';
import 'package:flutter/material.dart';
import 'screens/signup.dart';
import 'package:duobul/Provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: duoBulLightPurpleTheme,
      darkTheme: duoBulDarkPurpleTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const SignUpScreen(),
    );
  }
}
