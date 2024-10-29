import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para la codificación y decodificación de JSON
import '../../models/cart.dart'; // Asegúrate de tener tu modelo 'Cart' bien estructurado
import '../product/products_page.dart'; // Importa la página de productos
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../controllers/address_controller.dart';
import '../../providers/auth_provider.dart';
import '../../shared/shared.dart';
import '../../models/alquiler.dart';
import '../../models/detalle_alquiler.dart';
import '../../controllers/alquiler_controller.dart';
import '../../controllers/detalle_alquiler_controller.dart';

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
  List<Cart> cartItems = [];
  late double totalPrice = 0.0;
  String deliveryOption = "delivery"; // Estado para opción seleccionada
  double deliveryCost = 10.0; // Costo adicional de delivery
  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadDeliveryOption();
    _loadSelectedAddress(); // Cargar la dirección seleccionada
  }

  // Método para cargar los productos del carrito desde SharedPreferences
  Future<void> _loadCartItems() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userCartKey = 'cartItems_${user.id}';
    List<String>? cartItemsJson = prefs.getStringList(userCartKey);
    if (cartItemsJson != null) {
      setState(() {
        cartItems = cartItemsJson
            .map((jsonItem) => Cart.fromMap(jsonDecode(jsonItem)))
            .toList();
        _updateTotalPrice();
      });
    }
  }

  Future<void> _loadDeliveryOption() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryOption = prefs.getString('deliveryOption') ?? "delivery";
    });
  }

  Future<void> _loadSelectedAddress() async {
    // Cargar la dirección seleccionada desde el AddressController
    final addressController =
        Provider.of<AddressController>(context, listen: false);
    setState(() {
      selectedAddress = addressController.addresses.firstWhere(
          (address) => address.isSelected,
          orElse: () => addressController.addresses.first);
    });
  }

  // Método para guardar los productos del carrito en SharedPreferences
  Future<void> _saveCartItems() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userCartKey =
        'cartItems_${user.id}'; // Clave específica para el usuario
    List<String> cartItemsJson =
        cartItems.map((cart) => jsonEncode(cart.toMap())).toList();
    await prefs.setStringList(userCartKey, cartItemsJson);
  }

  // Método para eliminar un producto del carrito y actualizar SharedPreferences
  void _removeCartItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      _updateTotalPrice();
      _saveCartItems();
    });
  }

  void _updateTotalPrice() {
    double itemsTotal = cartItems.fold(0.0, (sum, cartItem) {
      return sum + (cartItem.precio * cartItem.rentalDays * cartItem.cantidad);
    });

    // Agregar el costo de delivery si está seleccionado
    setState(() {
      totalPrice =
          itemsTotal + (deliveryOption == "delivery" ? deliveryCost : 0.0);
    });
  }

  Future<void> clearSessionData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    String userCartKey = 'cartItems_${user.id}';
    await prefs.remove(userCartKey);
  }

  void _changeDeliveryOption(String option) {
    setState(() {
      deliveryOption = option;
    });
    _updateTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Alquiler'),
      ),
      drawer: const DrawerWidget(),
      body: Column(
        children: [
          // Opciones de entrega (Delivery o Retiro)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Row(
                    children: const [
                      Icon(Icons.delivery_dining),
                      SizedBox(width: 4),
                      Text("Delivery"),
                    ],
                  ),
                  selected: deliveryOption == "delivery",
                  onSelected: (selected) {
                    if (selected) _changeDeliveryOption("delivery");
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    children: const [
                      Icon(Icons.store),
                      SizedBox(width: 4),
                      Text("Retiro"),
                    ],
                  ),
                  selected: deliveryOption == "pickup",
                  onSelected: (selected) {
                    if (selected) _changeDeliveryOption("pickup");
                  },
                ),
              ],
            ),
          ),
          if (selectedAddress != null && deliveryOption == "delivery")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Dirección de entrega: ${selectedAddress!.street}"),
            ),
          Expanded(
            child: ListView.builder(
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
                    onPressed: () => _removeCartItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                );
              },
              child: const Text('Agregar más productos'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final user = Provider.of<AuthProvider>(context, listen: false).user;
                if (user == null) return;

                // Create new rental
                final alquiler = Alquiler(
                  id: 0, // The API will assign the real ID
                  usuarioId: user.id,
                  fechaReserva: DateTime.now(),
                  fechaDevolucion: DateTime.now().add(Duration(days: widget.rentalDays)),
                  precio: totalPrice,
                  estado: 'pendiente'
                );

                try {
                  // Create rental first
                  final alquilerController = AlquilerController();
                  final createdAlquiler = await alquilerController.createAlquiler(alquiler);

                  // Create rental details for each cart item
                  final detalleController = DetalleAlquilerController();
                  for (var item in cartItems) {
                    final detalle = DetalleAlquiler(
                      alquilerId: createdAlquiler.id,
                      productId: item.productId,
                      cantidad: item.cantidad,
                      precio: item.precio,
                      talla: item.talla,
                      color: item.color
                    );
                    await detalleController.createDetalleAlquiler(detalle);
                  }

                  // Clear cart after successful creation
                  await clearSessionData();
                  
                  // Show success message and navigate back
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alquiler creado exitosamente'))
                  );
                  Navigator.pushNamed(
                context,
                '/rental',
                arguments: alquiler,
              )
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear el alquiler: $e'))
                  );
                }
              },
              child: Text('Ir a Pagar (Bs.${totalPrice.toStringAsFixed(2)})'),
            ),          ],
        ),
      ),
    );
  }
}
