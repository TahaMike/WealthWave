import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wealthwave/core/utils/theme/app_custom_theme.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WealthWave',
      theme: AppCustomTheme.lightTheme(),   // Custom light theme
      darkTheme: AppCustomTheme.darkTheme(), // Optional: Dark theme
      themeMode: ThemeMode.dark,  // Automatically switch based on system setting
      home: const HomePage(),
    );
  }
}
