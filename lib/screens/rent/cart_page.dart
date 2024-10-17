import 'package:flutter/material.dart';
import '../../models/product.dart';

class CartPage extends StatelessWidget {
  final List<Product> cartItems;
    final int rentalDays;
  final double totalPrice;
  

  const CartPage({Key? key, required this.cartItems, required this.rentalDays, required this.totalPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Alquiler'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('No hay productos en el carrito.'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final product = cartItems[index];
                final productTotal = product.precio * rentalDays;
                return ListTile(
                  leading: Image.network(
                    product.imagen,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.nombre),
                  subtitle: Text(
                      'Precio por día: Bs.${product.precio.toStringAsFixed(2)}\n'
                    'Total por $rentalDays día(s): Bs.${productTotal.toStringAsFixed(2)}\n'
                    'Talla: ${product.talla.isNotEmpty ? product.talla.join(', ') : 'No seleccionada'}\n'
                    'Color: ${product.color.isNotEmpty ? product.color.join(', ') : 'No seleccionado'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      //  lógica para eliminar un producto del carrito
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            //  lógica para proceder al pago o checkout
          },
          //
          child: Text('Ir a Pagar (Bs.$totalPrice)'),
        ),
      ),
    );
  }
}
