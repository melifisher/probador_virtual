import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<User> login(String username, String password) async {
    User user = await _authService.login(username, password);

    // Guarda el user_id en SharedPreferences después del inicio de sesión exitoso
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
 print("User ID guardado en SharedPreferences: ${user.id}");
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
   // Función para obtener el user_id desde SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
