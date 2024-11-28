import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/devolucion_controller.dart';
import '../../models/devolucion.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class DevolucionListPage extends StatefulWidget {
  const DevolucionListPage({super.key});
  @override
  _DevolucionListPageState createState() => _DevolucionListPageState();
}

class _DevolucionListPageState extends State<DevolucionListPage> {
  final DevolucionController _controller = DevolucionController();
  List<Devolucion> _devoluciones = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _loadDevoluciones();
  }

  Future<void> _loadDevoluciones() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    user = authProvider.user;

    if (user != null) {
      List<Devolucion> devoluciones;
      if (user!.rol == 'administrator') {
        devoluciones = await _controller.getDevoluciones();
      } else {
        devoluciones = await _controller.getDevolucionesByUsuario(user!.id);
      }
      setState(() {
        _devoluciones = devoluciones;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Devoluciones')),
      body: ListView.builder(
        itemCount: _devoluciones.length,
        itemBuilder: (context, index) {
          final devolucion = _devoluciones[index];
          return ListTile(
            title: Text('Devolución ${devolucion.id}'),
            subtitle: Text('Fecha: ${devolucion.fechaDevuelto}'),
            trailing: Text('Estado: ${devolucion.estado}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/devolucion',
                arguments: devolucion,
              ).then((_) => _loadDevoluciones());
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
                  '/devolucion',
                ).then((_) => _loadDevoluciones());
              },
            )
          : null,
    );
  }
}
