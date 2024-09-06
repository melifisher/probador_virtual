import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';

class ProductScreen extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());
  ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Obx(
        () {
          if (controller.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final producto = controller.products[index];
              return ListTile(
                title: Text(producto.nombre),
                subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                leading: Image.network(producto.imagen,
                    width: 50, height: 50, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementa la lógica para añadir un nuevo producto
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
