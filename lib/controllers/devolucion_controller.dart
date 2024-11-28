import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/devolucion.dart';
import '../config/environment/environment.dart';

class DevolucionController {
  DevolucionController();

  Future<List<Devolucion>> getDevoluciones() async {
    try {
      final response =
          await http.get(Uri.parse('${Environment.apiUrl}/api/devoluciones'));
      if (response.statusCode == 200) {
        final List<dynamic> devolucionesJson = json.decode(response.body);
        return devolucionesJson
            .map((json) => Devolucion.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load devoluciones');
      }
    } catch (e) {
      print('Error loading devoluciones: $e');
      throw Exception(e);
    }
  }

  Future<Devolucion> getDevolucion(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${Environment.apiUrl}/api/devoluciones/$id'));
      if (response.statusCode == 200) {
        final dynamic devolucionJson = json.decode(response.body);
        return Devolucion.fromMap(devolucionJson);
      } else {
        throw Exception('Failed to load devolucion');
      }
    } catch (e) {
      print('Error loading devolucion: $e');
      throw Exception(e);
    }
  }

  Future<Devolucion> createDevolucion(Devolucion devolucion) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/devoluciones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(devolucion.toMap()),
    );
    if (response.statusCode == 201) {
      return Devolucion.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create devolucion');
    }
  }

  Future<Devolucion> updateDevolucion(Devolucion devolucion) async {
    final response = await http.put(
      Uri.parse('${Environment.apiUrl}/api/devoluciones/${devolucion.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(devolucion.toMap()),
    );
    if (response.statusCode == 200) {
      return Devolucion.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update devolucion');
    }
  }

  Future<void> deleteDevolucion(int id) async {
    final response = await http
        .delete(Uri.parse('${Environment.apiUrl}/api/devoluciones/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete devolucion');
    }
  }

  Future<List<Devolucion>> getDevolucionesByUsuario(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse(
          '${Environment.apiUrl}/api/devoluciones/usuario/$usuarioId'));
      if (response.statusCode == 200) {
        final List<dynamic> devolucionesJson = json.decode(response.body);
        return devolucionesJson
            .map((json) => Devolucion.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load devoluciones');
      }
    } catch (e) {
      print('Error loading devoluciones: $e');
      throw Exception(e);
    }
  }
}
