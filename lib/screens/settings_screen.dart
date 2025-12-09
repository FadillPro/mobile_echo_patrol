import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Logout'),
            trailing: const Icon(Icons.exit_to_app, color: Colors.red),
            onTap: () {

              ref.read(authProvider.notifier).logout();
            },
          ),
          // Pengaturan lain (Jika ada)
        ],
      ),
    );
  }
}