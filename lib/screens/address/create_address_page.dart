import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:probador_virtual/screens/address/map_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/environment/environment.dart';

class CreateAddressPage extends StatefulWidget {
  @override
  _CreateAddressPageState createState() => _CreateAddressPageState();
}

class _CreateAddressPageState extends State<CreateAddressPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();
  TextEditingController referencePointController = TextEditingController();

  LatLng? selectedLocation;

  Future<void> _openMap() async {
    // Lógica para abrir Google Maps en una nueva pantalla
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(),
      ),
    );
    if (result != null && result is LatLng) {
      setState(() {
        selectedLocation = result;
        referencePointController.text =
            'Lat: ${result.latitude}, Lng: ${result.longitude}';
      });
    }
  }

  Future<void> _saveAddress() async {
    if (selectedLocation != null) {
      // Obtén el user_id desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id'); // Carga el user_id guardado

      if (userId == null) {
        print("Error: No se encontró el user_id en SharedPreferences.");
        return;
      }

      try {
        final url = '${Environment.apiUrl}/api/address';
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId, // Usa el user_id obtenido de SharedPreferences
            "street": addressController.text,
            "number": neighborhoodController.text,
            "city": "Tu ciudad", // Añade el campo de ciudad si es necesario
            "latitude": selectedLocation!.latitude, // Añade latitud
            "longitude": selectedLocation!.longitude // Añade longitud
          }),
        );
        if (response.statusCode == 201) {
          final newAddress = jsonDecode(response.body);
          print("Dirección guardada exitosamente");
          Navigator.pop(
              context, newAddress); // Envía un valor `true` al regresar
        } else {
          print("Error al guardar la dirección");
        }
      } catch (e) {
        print('Error address: $e');
        throw Exception(e);
      }
    } else {
      print("Seleccione una ubicación en el mapa.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva dirección"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Dirección",
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: neighborhoodController,
              decoration: InputDecoration(
                labelText: "Barrio",
                prefixIcon: Icon(Icons.home),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: referencePointController,
              decoration: InputDecoration(
                labelText: "Punto de referencia",
                prefixIcon: Icon(Icons.map),
              ),
              readOnly: true,
              onTap: _openMap,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text("Añadir dirección"),
            ),
          ],
        ),
      ),
    );
  }
}
