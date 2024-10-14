import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alquiler.dart';
import '../config/environment/environment.dart';

class AlquilerController {
  AlquilerController();

  Future<List<Alquiler>> getAlquileres(int? usuarioId) async {
    try {
      final response = usuarioId == null
          ? await http.get(Uri.parse('${Environment.apiUrl}/api/rentals'))
          : await http.get(
              Uri.parse('${Environment.apiUrl}/api/rentals/user/$usuarioId'));
      if (response.statusCode == 200) {
        final List<dynamic> alquileresJson = json.decode(response.body);
        return alquileresJson.map((json) => Alquiler.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load rentals');
      }
    } catch (e) {
      print('Error loading rentals: $e');
      throw Exception(e);
    }
  }

  Future<Alquiler> createAlquiler(Alquiler alquiler) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/rentals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alquiler.toMap()),
    );
    if (response.statusCode == 201) {
      return Alquiler.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create alquiler');
    }
  }

  Future<Alquiler> updateAlquiler(Alquiler alquiler) async {
    final response = await http.put(
      Uri.parse('${Environment.apiUrl}/api/rentals/${alquiler.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alquiler.toMap()),
    );
    if (response.statusCode == 200) {
      return Alquiler.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update alquiler');
    }
  }

  Future<void> deleteAlquiler(int id) async {
    final response =
        await http.delete(Uri.parse('${Environment.apiUrl}/api/rentals/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete alquiler');
    }
  }
}
