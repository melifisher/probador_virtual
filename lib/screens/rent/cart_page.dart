import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/cart.dart';

class CartPage extends StatelessWidget {
  final List<Cart> cartItems; 
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
                final cartItem = cartItems[index];
                 final productTotal = cartItem.precio* cartItem.rentalDays * cartItem.cantidad; 
                return ListTile(
                  leading: Image.network(
                    cartItem.imagen,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(cartItem.nombre),
                  subtitle: Text(
                         'Cantidad: ${cartItem.cantidad}\n'
                    'Color: ${cartItem.color}\n'
                    'Talla: ${cartItem.talla}\n'
                    'Días de alquiler: ${cartItem.rentalDays}\n'
                    'Precio por día: Bs.${cartItem.precio.toStringAsFixed(2)}\n'  // Usamos directamente `precio`
                    'Total por el producto: Bs.${productTotal.toStringAsFixed(2)}'
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
