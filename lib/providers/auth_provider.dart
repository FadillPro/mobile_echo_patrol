import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isLoggedIn;
  AuthState(this.isLoggedIn);
}

class AuthNotifier extends StateNotifier<AuthState> 
{
  final SharedPreferences _prefs;
  static const _sessionKey = 'isLoggedIn';

  AuthNotifier(this._prefs) : super(AuthState(_prefs.getBool(_sessionKey) ?? false));

  Future<void> login() async {
    await _prefs.setBool(_sessionKey, true);
    state = AuthState(true);
  }

  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
    state = AuthState(false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});