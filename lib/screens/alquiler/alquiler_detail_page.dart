import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/alquiler_controller.dart';
import '../../controllers/detalle_alquiler_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/alquiler.dart';
import '../../models/detalle_alquiler.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';

class AlquilerDetailPage extends StatefulWidget {
  final Alquiler? rental;

  const AlquilerDetailPage({super.key, this.rental});

  @override
  _AlquilerDetailPageState createState() => _AlquilerDetailPageState();
}

class _AlquilerDetailPageState extends State<AlquilerDetailPage> {
  final AlquilerController _alquilerController = AlquilerController();
  final DetalleAlquilerController _detalleAlquilerController =
      DetalleAlquilerController();
  final ProductController _productController = ProductController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userIdController;
  late TextEditingController _fechaReservaController;
  late TextEditingController _fechaDevolucionController;
  late TextEditingController _precioController;
  late TextEditingController _estadoController;
  bool _isEditing = false;
  List<DetalleAlquiler> _detallesAlquiler = [];
  Map<int, Product> _products = {};

  @override
  void initState() {
    super.initState();
    _userIdController =
        TextEditingController(text: widget.rental?.usuarioId.toString() ?? '');
    _fechaReservaController = TextEditingController(
        text: widget.rental?.fechaReserva.toString() ?? '');
    _fechaDevolucionController = TextEditingController(
        text: widget.rental?.fechaDevolucion.toString() ?? '');
    _precioController =
        TextEditingController(text: widget.rental?.precio.toString() ?? '');
    _estadoController =
        TextEditingController(text: widget.rental?.estado ?? '');
    _isEditing = widget.rental == null;
    _loadDetallesAlquiler();
  }

  Future<void> _loadDetallesAlquiler() async {
    if (widget.rental != null) {
      final detalles = await _detalleAlquilerController
          .getDetallesAlquiler(widget.rental!.id);
      setState(() {
        _detallesAlquiler = detalles;
      });
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    for (var detalle in _detallesAlquiler) {
      if (!_products.containsKey(detalle.productId)) {
        final product = await _productController.getProduct(detalle.productId);
        setState(() {
          _products[detalle.productId] = product;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.rol;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.rental == null ? 'Add Alquiler' : 'Alquiler Details'),
        actions: [
          if (userRole == 'administrator' && widget.rental != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveAlquiler();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (userRole == 'administrator')
                      TextFormField(
                        controller: _userIdController,
                        decoration:
                            const InputDecoration(labelText: 'Usuario Id'),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a user id';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      controller: _fechaReservaController,
                      decoration:
                          const InputDecoration(labelText: 'Fecha de Reserva'),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reservation date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fechaDevolucionController,
                      decoration: const InputDecoration(
                          labelText: 'Fecha de Devolución'),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a return date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _precioController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cost';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a state';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Productos alquilados:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _detallesAlquiler.length,
                itemBuilder: (context, index) {
                  final detalle = _detallesAlquiler[index];
                  final product = _products[detalle.productId];
                  return Card(
                    child: ListTile(
                      leading: product != null && product.imagen != ''
                          ? Image.network(product.imagen,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text(product?.nombre ?? 'Producto no encontrado'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Talla: ${detalle.talla}'),
                          Text('Color: ${detalle.color}'),
                          Text(
                              'Precio: \$${detalle.precio.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: userRole == 'administrator'
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await _detalleAlquilerController
                                      .deleteDetalleAlquiler(
                                          widget.rental!.id, product!.id);
                                  setState(() {
                                    _detallesAlquiler.removeAt(index);
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
              if (userRole == 'administrator' &&
                  widget.rental != null &&
                  !_isEditing) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _alquilerController
                            .deleteAlquiler(widget.rental!.id);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ),
              ],
              if (userRole == 'administrator' &&
                  widget.rental == null &&
                  _isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAlquiler,
                  child: const Text('Add'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveAlquiler() async {
    if (_formKey.currentState!.validate()) {
      Alquiler rental = Alquiler(
        id: widget.rental?.id ?? 0,
        usuarioId: int.parse(_userIdController.text),
        fechaReserva: DateTime.parse(_fechaReservaController.text),
        fechaDevolucion: DateTime.parse(_fechaDevolucionController.text),
        precio: double.parse(_precioController.text),
        estado: _estadoController.text,
      );
      try {
        if (widget.rental == null) {
          await _alquilerController.createAlquiler(rental);
        } else {
          await _alquilerController.updateAlquiler(rental);
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
    _userIdController.dispose();
    _fechaReservaController.dispose();
    _fechaDevolucionController.dispose();
    _precioController.dispose();
    _estadoController.dispose();
    super.dispose();
  }
}
