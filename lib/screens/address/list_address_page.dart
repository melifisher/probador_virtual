import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListAddressPage extends StatefulWidget {
  @override
  _ListAddressPageState createState() => _ListAddressPageState();
}

class _ListAddressPageState extends State<ListAddressPage> {
  List<dynamic> addresses = [];
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

Future<void> _fetchAddresses() async {
    // Obtén el user_id de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id'); // Obtiene el ID del usuario autenticado

    if (userId != null) {
      // Construye la URL con el user_id dinámico
      final response = await http.get(Uri.parse('http://localhost:3000/api/address/$userId'));

      if (response.statusCode == 200) {
        setState(() {
          addresses = json.decode(response.body);
           // Recupera el ID de la dirección seleccionada 
          selectedAddressId = prefs.getString('selectedAddressId') ?? addresses.first['id'].toString();
        });
      } else {
        print('Error al obtener direcciones');
      }
    } else {
      print('No se encontró user_id en SharedPreferences');
    }
  }

  void _selectAddress(String? addressId) {
    setState(() {
      selectedAddressId = addressId;
    });
  }
    Future<void> _navigateToAddAddress() async {
    
    final newAddress = await Navigator.pushNamed(context, '/addAddress');
    if (newAddress != null) {
      setState(() {
        addresses.add(newAddress); // Añade nueva dirección
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dirección'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
              onPressed: _navigateToAddAddress, 
          ),
        ],
      ),
      body: addresses.isEmpty
          ? Center(child: Text('No tienes direcciones guardadas'))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return RadioListTile<String>(
                  title: Text(address['street']),
                  subtitle: Text(address['city']),
                  value: address['id'].toString(),
                  groupValue: selectedAddressId,
                  onChanged: (value) {
                    _selectAddress(value);
                  },
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
            onPressed: () async {
            if (selectedAddressId != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('selectedAddressId', selectedAddressId!);
              
          
              print('Dirección seleccionada: $selectedAddressId');

              // Actualiza el estado para reflejar la selección en la vista
              setState(() {
                selectedAddressId = selectedAddressId;
              });
               Navigator.pop(context, selectedAddressId);
            //  Navigator.pop(context, selectedAddressId);
            }
          },
          child: Text('Aceptar'),
        ),
      ),
    );
  }
}
