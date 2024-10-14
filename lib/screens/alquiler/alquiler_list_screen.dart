import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/alquiler_controller.dart';
import '../../models/alquiler.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class AlquilerListScreen extends StatefulWidget {
  const AlquilerListScreen({super.key});
  @override
  _AlquilerListScreenState createState() => _AlquilerListScreenState();
}

class _AlquilerListScreenState extends State<AlquilerListScreen> {
  final AlquilerController _controller = AlquilerController();
  List<Alquiler> _alquileres = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _loadAlquileres();
  }

  Future<void> _loadAlquileres() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    user = authProvider.user;

    if (user != null) {
      List<Alquiler> alquileres;
      if (user!.rol == 'administrator') {
        alquileres = await _controller.getAlquileres(null);
      } else {
        alquileres = await _controller.getAlquileres(user!.id);
      }
      setState(() {
        _alquileres = alquileres;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Alquileres')),
      body: ListView.builder(
        itemCount: _alquileres.length,
        itemBuilder: (context, index) {
          final alquiler = _alquileres[index];
          return ListTile(
            title: Text('Alquiler ${alquiler.id}'),
            subtitle:
                Text('${alquiler.fechaReserva} - ${alquiler.fechaDevolucion}'),
            trailing: Text('\$${alquiler.precio}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/rental',
                arguments: alquiler,
              ).then((_) => _loadAlquileres());
            },
          );
        },
      ),
      floatingActionButton: user?.rol == 'administrator'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/rental',
                ).then((_) => _loadAlquileres());
              },
            )
          : null,
    );
  }
}
