import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

// [Setup di main.dart, Bagian dari MAHASISWA 1]
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ambil instance Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        // Override provider dengan instance yang sudah di-init
        authProvider.overrideWith((ref) => AuthNotifier(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wajib menggunakan ref.watch untuk memantau status login (MAHASISWA 1 - Session Bypass)
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'EcoPatrol',
      theme: ThemeData(primarySwatch: Colors.green),
      // Logic: Jika isLoggedIn, ke Dashboard, jika tidak, ke Login
      home: authState.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}