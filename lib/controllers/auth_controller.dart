import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<User> login(String username, String password) async {
    return await _authService.login(username, password);
  }

  Future<User> register(String username, String password, String role) async {
    return await _authService.register(username, password, role);
  }
}
