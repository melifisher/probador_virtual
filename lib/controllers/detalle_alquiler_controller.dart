import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detalle_alquiler.dart';
import '../config/environment/environment.dart';

class DetalleAlquilerController {
  DetalleAlquilerController();

  Future<List<DetalleAlquiler>> getDetallesAlquiler(int alquilerId) async {
    try {
      final response = await http.get(Uri.parse(
          '${Environment.apiUrl}/api/rental-details/rental/$alquilerId'));
      if (response.statusCode == 200) {
        final List<dynamic> detallesJson = json.decode(response.body);
        return detallesJson
            .map((json) => DetalleAlquiler.fromMap(json))
            .toList();
      } else {
        throw Exception('Failed to load rental details');
      }
    } catch (e) {
      print('Error loading rental details: $e');
      throw Exception(e);
    }
  }

  Future<DetalleAlquiler> createDetalleAlquiler(
      DetalleAlquiler detalleAlquiler) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/rental-details'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(detalleAlquiler.toMap()),
    );
    if (response.statusCode == 201) {
      return DetalleAlquiler.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create rental detail');
    }
  }

  Future<DetalleAlquiler> updateDetalleAlquiler(
      DetalleAlquiler detalleAlquiler) async {
    final response = await http.put(
      Uri.parse(
          '${Environment.apiUrl}/api/rental-details/${detalleAlquiler.alquilerId}/${detalleAlquiler.productId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(detalleAlquiler.toMap()),
    );
    if (response.statusCode == 200) {
      return DetalleAlquiler.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update rental detail');
    }
  }

  Future<void> deleteDetalleAlquiler(int alquilerId, int productId) async {
    final response = await http.delete(Uri.parse(
        '${Environment.apiUrl}/api/rental-details/$alquilerId/$productId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete rental detail');
    }
  }
}
