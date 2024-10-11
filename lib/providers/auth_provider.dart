import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  Future<bool> login(String username, String password) async {
    try {
      _user = await _authService.login(username, password);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password, String role) async {
    try {
      _user = await _authService.register(username, password, role);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
