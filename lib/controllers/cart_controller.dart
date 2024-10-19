import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';
import '../config/environment/environment.dart';

class CartController {
  CartController();

  // Obtener los productos del carrito para un usuario
  Future<List<Cart>> getCartItems(int userId) async {
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

  // Añadir un producto al carrito
  Future<Cart> addToCart(Cart cart) async {
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

  // Eliminar un producto del carrito
  Future<void> deleteCartItem(int id) async {
    final response =
        await http.delete(Uri.parse('${Environment.apiUrl}/api/cart/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete cart item');
    }
  }
}
