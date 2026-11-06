import 'package:flutter/material.dart';

import 'habi_colors.dart';
import 'splash_screen.dart';

void main() {
  runApp(const HabiApp());
}

class HabiApp extends StatelessWidget {
  const HabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HABI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: HabiColors.navy,
        colorScheme: const ColorScheme.dark(
          primary: HabiColors.gold,
          surface: HabiColors.navy,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}