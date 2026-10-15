import 'package:flutter/material.dart';
import 'package:movies_app/home_screen.dart';

void main() {
  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineScope',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10111B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC857),
          surface: Color(0xFF1D1F2D),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
