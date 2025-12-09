import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login EcoPatrol')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const TextField(decoration: InputDecoration(labelText: 'Username')),
              const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 20),
              // Tombol Login: Memanggil method login dari AuthNotifier
              ElevatedButton(
                onPressed: () {
                  // Panggil .notifier untuk mengubah state
                  ref.read(authProvider.notifier).login();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}