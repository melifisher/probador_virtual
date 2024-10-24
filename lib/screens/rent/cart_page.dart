import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para la codificación y decodificación de JSON
import '../../models/cart.dart'; // Asegúrate de tener tu modelo 'Cart' bien estructurado
import '../product/products_page.dart'; // Importa la página de productos
  

class CartPage extends StatefulWidget {
  final List<Cart> cartItems;
  final int rentalDays;
  final double totalPrice;

  const CartPage(
      {Key? key,
      required this.cartItems,
      required this.rentalDays,
      required this.totalPrice})
      : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Cart>
      cartItems; // Haremos que esta variable sea dinámica para manejar el estado
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    cartItems =
        widget.cartItems; // Inicializamos con los valores pasados al widget
    totalPrice = widget.totalPrice;
    _loadCartItems(); // Cargar productos del carrito desde SharedPreferences
  }

  // Método para cargar los productos del carrito desde SharedPreferences
  Future<void> _loadCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');
    if (cartItemsJson != null) {
      setState(() {
        cartItems = cartItemsJson
            .map((jsonItem) => Cart.fromMap(jsonDecode(jsonItem)))
            .toList();
        totalPrice = cartItems.fold(0.0, (sum, cartItem) {
          return sum +
              (cartItem.precio * cartItem.rentalDays * cartItem.cantidad);
        });
      });
    }
  }

  // Método para guardar los productos del carrito en SharedPreferences
  Future<void> _saveCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson =
        cartItems.map((cart) => jsonEncode(cart.toMap())).toList();
    await prefs.setStringList('cartItems', cartItemsJson);
  }

  // Método para eliminar un producto del carrito y actualizar SharedPreferences
  void _removeCartItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      totalPrice = cartItems.fold(0.0, (sum, cartItem) {
        return sum +
            (cartItem.precio * cartItem.rentalDays * cartItem.cantidad);
      });
      _saveCartItems(); // Guardamos el estado actualizado
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcular el precio total basado en el carrito actual
    double calculatedTotalPrice = cartItems.fold(0.0, (sum, cartItem) {
      return sum + (cartItem.precio * cartItem.rentalDays * cartItem.cantidad);
    });

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
                final productTotal =
                    cartItem.precio * cartItem.rentalDays * cartItem.cantidad;

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
                    'Precio por día: Bs.${cartItem.precio.toStringAsFixed(2)}\n'
                    'Total Bs.${productTotal.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeCartItem(
                          index); // Eliminar el producto y actualizar el carrito
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Redirigir a la página de productos
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                );
              },
              child: const Text('Agregar más productos'),
            ),
            const SizedBox(height: 8), // Espacio entre los botones
            ElevatedButton(
              onPressed: () {
                // Lógica para proceder al pago o checkout
              },
              child: Text(
                  'Ir a Pagar (Bs.${calculatedTotalPrice.toStringAsFixed(2)})'),
            ),
          ],
        ),
      ),
    );
  }
}
