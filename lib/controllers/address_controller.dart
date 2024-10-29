import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/address.dart';
import '../config/environment/environment.dart';
import 'package:http/http.dart' as http;

class AddressController with ChangeNotifier {
  List<Address> _addresses = [];
  Address? _selectedAddress; // Dirección actualmente seleccionada

  List<Address> get addresses => _addresses;

  AddressController() {
    loadAddresses();
  }


  // Cargar direcciones desde SharedPreferences
  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id'); // Carga el user_id

    if (userId != null) {
      final response = await http
          .get(Uri.parse('${Environment.apiUrl}/api/address/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> decodedAddresses = json.decode(response.body);
        _addresses = decodedAddresses
            .map((addressMap) => Address.fromMap(addressMap))
            .toList();
        notifyListeners();
      } else {
        print('Error al obtener direcciones');
      }
    } else {
      print('No hay user_id guardado');
    }
  }
  // Método para seleccionar una dirección
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners(); // Notifica a los widgets para actualizarse
  }
  // Agregar una nueva dirección en el backend
  Future<void> addAddress(Address newAddress) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      final response = await http.post(
        Uri.parse('${Environment.apiUrl}/api/address'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId, // Incluye el user_id en la petición
          ...newAddress.toMap() // Añade los otros datos de la dirección
        }),
      );

      if (response.statusCode == 201) {
        final addedAddress = Address.fromMap(json.decode(response.body));
        _addresses.add(addedAddress);
        notifyListeners();
      } else {
        print('Error al guardar dirección');
      }
    } else {
      print('No hay user_id guardado');
    }
  }

  // Eliminar una dirección en el backend
  Future<void> removeAddress(String addressId) async {
    final response = await http
        .delete(Uri.parse('${Environment.apiUrl}/api/address/$addressId'));

    if (response.statusCode == 204) {
      _addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
    } else {
      print('Error al eliminar dirección');
    }
  }

  // Guardar direcciones en SharedPreferences
  Future<void> _saveAddresses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> addressMaps =
        _addresses.map((address) => address.toMap()).toList();
    await prefs.setString('addresses', json.encode(addressMaps));
  }
}
