import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';
import '../config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController {
  CartController();

  // Guardar el carrito en SharedPreferences
  Future<void> saveCartItems(List<Cart> cartItems) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = cartItems.map((cart) => jsonEncode(cart.toMap())).toList();
    await prefs.setStringList('cartItems', cartItemsJson);  // Guardar el carrito como una lista de strings
  }

  // Cargar el carrito desde SharedPreferences
  Future<List<Cart>> loadCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');
    if (cartItemsJson != null) {
      return cartItemsJson.map((jsonItem) => Cart.fromMap(jsonDecode(jsonItem))).toList();
    }
    return [];  // Si no hay productos, devolver una lista vacía
  }

  // Añadir un producto al carrito y guardarlo en SharedPreferences
  Future<void> addToCart(Cart cart) async {
    List<Cart> cartItems = await loadCartItems();  // Cargar los items existentes
    cartItems.add(cart);  // Añadir el nuevo producto
    await saveCartItems(cartItems);  // Guardar el carrito actualizado en SharedPreferences
  }

  // Eliminar un producto del carrito y guardarlo en SharedPreferences
  Future<void> removeFromCart(int productId) async {
    List<Cart> cartItems = await loadCartItems();
    cartItems.removeWhere((item) => item.productId == productId);  // Eliminar el producto por ID
    await saveCartItems(cartItems);  // Guardar el carrito actualizado en SharedPreferences
  }

  // Limpiar todo el carrito (por ejemplo, después de la compra)
  Future<void> clearCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');  // Eliminar los productos guardados en el carrito
  }

  // Métodos para interactuar con el backend (si es necesario)
  Future<List<Cart>> getCartItemsFromBackend(int userId) async {
    try {
      final response = await http.get(Uri.parse('${Environment.apiUrl}/api/cart/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> cartItemsJson = json.decode(response.body);
        return cartItemsJson.map((json) => Cart.fromMap(json)).toList();
      } else {
        throw Exception('Error al obtener los productos del carrito');
      }
    } catch (e) {
      print('Error al obtener el carrito: $e');
      throw Exception(e);
    }
  }

  // Enviar el carrito al backend cuando sea necesario
  Future<Cart> sendCartToBackend(Cart cart) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cart.toMap()),
    );
    if (response.statusCode == 201) {
      return Cart.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product to cart');
    }
  }

  // Eliminar un producto del carrito en el backend
  Future<void> deleteCartItemFromBackend(int id) async {
    final response = await http.delete(Uri.parse('${Environment.apiUrl}/api/cart/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete cart item');
    }
  }
}
