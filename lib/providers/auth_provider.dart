import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

// Al iniciar el proveedor, carga el user_id si está guardado
  AuthProvider() {
    _loadUserId();
  }
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    if (userId != null) {
      // Aquí deberías cargar más detalles del usuario si tienes la función en AuthService
      _user = await _authService.getUserById(userId); // Suponiendo que tienes este método
      notifyListeners();
    }
  }
  Future<bool> login(String username, String password) async {
    try {
      _user = await _authService.login(username, password);
      // Guarda el user_id en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', _user!.id); // Asume que _user.id es int
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password, String role) async {
    try {
      _user = await _authService.register(username, password, role);
       // Guarda el user_id en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', _user!.id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('alquilerOption'); // Eliminar opción seleccionada
  await prefs.remove('startDate'); // Remueve la fecha de inicio
  await prefs.remove('endDate'); // Remueve la fecha de fin
  await prefs.remove('cartItems_${_user?.id}'); // Elimina el carrito del usuario actual
 
  _user = null;
  notifyListeners();
}

}
