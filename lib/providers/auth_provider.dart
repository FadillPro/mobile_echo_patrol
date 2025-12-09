import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State yang hanya menyimpan status login
class AuthState {
  final bool isLoggedIn;
  AuthState(this.isLoggedIn);
}

// StateNotifier untuk mengelola status login & logout
class AuthNotifier extends StateNotifier<AuthState> 
{
  final SharedPreferences _prefs;
  static const _sessionKey = 'isLoggedIn';

  AuthNotifier(this._prefs) : super(AuthState(_prefs.getBool(_sessionKey) ?? false));

  // Method untuk Login (Simulasi)
  Future<void> login() async {
    // Logika login sesungguhnya (cek user/password) dihilangkan
    await _prefs.setBool(_sessionKey, true);
    state = AuthState(true);
  }

  // Method untuk Logout (Dihapus di Settings, MAHASISWA 1)
  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
    state = AuthState(false);
  }
}

// Global Provider (Gunakan AsyncValue jika SharedPreferences perlu di-await)
// Untuk kesederhanaan, kita anggap SharedPreferences sudah di-init di main.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});