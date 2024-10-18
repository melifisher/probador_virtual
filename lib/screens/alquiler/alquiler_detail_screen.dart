import 'package:flutter/material.dart';
import '../../controllers/alquiler_controller.dart';
import '../../models/alquiler.dart';

class AlquilerDetailScreen extends StatelessWidget {
  final Alquiler alquiler;
  final AlquilerController _controller = AlquilerController();

  AlquilerDetailScreen({required this.alquiler});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Alquiler')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${alquiler.id}'),
            Text('Usuario ID: ${alquiler.usuarioId}'),
            Text('Fecha Inicio: ${alquiler.fechaReserva}'),
            Text('Fecha Fin: ${alquiler.fechaDevolucion}'),
            Text('Costo Total: \$${alquiler.precio}'),
            Text('Estado: ${alquiler.estado}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlquilerEditScreen(alquiler: alquiler),
            ),
          ); */
        },
      ),
    );
  }
}
