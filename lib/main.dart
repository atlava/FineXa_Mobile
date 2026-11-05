import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const FinexaApp());

class FinexaApp extends StatelessWidget {
  const FinexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FineXa',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.dark,
        ),
        textTheme: ThemeData.dark().textTheme,
      ),
      home: const LoginScreen(),
    );
  }
}
