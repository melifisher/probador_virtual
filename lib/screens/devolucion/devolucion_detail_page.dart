import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/devolucion_controller.dart';
import '../../models/devolucion.dart';
import '../../providers/auth_provider.dart';

class DevolucionDetailPage extends StatefulWidget {
  final Devolucion? devolucion;

  const DevolucionDetailPage({super.key, this.devolucion});

  @override
  _DevolucionDetailPageState createState() => _DevolucionDetailPageState();
}

class _DevolucionDetailPageState extends State<DevolucionDetailPage> {
  final DevolucionController _controller = DevolucionController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _alquilerIdController;
  late TextEditingController _fechaDevolucionController;
  late TextEditingController _diasRetrasoController;
  late String _estadoValue;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _alquilerIdController = TextEditingController(
        text: widget.devolucion?.alquilerId.toString() ?? '');
    _fechaDevolucionController = TextEditingController(
        text: widget.devolucion?.fechaDevuelto.toString() ?? '');
    _diasRetrasoController = TextEditingController(
        text: widget.devolucion?.diasRetraso.toString() ?? '0');
    _estadoValue = widget.devolucion?.estado ?? 'pendiente';
    _isEditing = widget.devolucion == null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.rol;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.devolucion == null
            ? 'Nueva Devolución'
            : 'Detalles de Devolución'),
        actions: [
          if (userRole == 'administrator' && widget.devolucion != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveDevolucion();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _alquilerIdController,
                decoration: const InputDecoration(labelText: 'ID de Alquiler'),
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el ID del alquiler';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaDevolucionController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Devolución'),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de devolución';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _diasRetrasoController,
                decoration: const InputDecoration(labelText: 'Días de Retraso'),
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los días de retraso';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _estadoValue,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['pendiente', 'devuelto', 'retraso']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: _isEditing
                    ? (String? newValue) {
                        setState(() {
                          _estadoValue = newValue!;
                        });
                      }
                    : null,
              ),
              if (userRole == 'administrator') ...[
                const SizedBox(height: 20),
                if (widget.devolucion != null && !_isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _controller
                            .deleteDevolucion(widget.devolucion!.id);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Eliminar'),
                  ),
                if (widget.devolucion == null)
                  ElevatedButton(
                    onPressed: _saveDevolucion,
                    child: const Text('Crear'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveDevolucion() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id ?? 0;

      Devolucion devolucion = Devolucion(
        id: widget.devolucion?.id ?? 0,
        usuarioId: userId,
        alquilerId: int.parse(_alquilerIdController.text),
        fechaDevuelto: DateTime.parse(_fechaDevolucionController.text),
        diasRetraso: int.parse(_diasRetrasoController.text),
        estado: _estadoValue,
      );

      try {
        if (widget.devolucion == null) {
          await _controller.createDevolucion(devolucion);
        } else {
          await _controller.updateDevolucion(devolucion);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _alquilerIdController.dispose();
    _fechaDevolucionController.dispose();
    _diasRetrasoController.dispose();
    super.dispose();
  }
}
