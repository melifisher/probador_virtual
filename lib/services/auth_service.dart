import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/environment/environment.dart';
import '../models/user.dart';

class AuthService {
  //final String baseUrl = '${Environment.apiUrl}/api';

  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<User> register(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': username,
          'password': password,
          'rol': role,
        }),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }
}
