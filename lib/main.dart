import 'package:flutter/material.dart';

import 'common/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.ocrScanner,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
