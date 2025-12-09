import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import semua screens yang digunakan dalam routing 
import 'screens/login_screen.dart'; // Diperlukan untuk routing



void main() {
  // Wajib membungkus aplikasi dengan ProviderScope agar Riverpod berfungsi
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}