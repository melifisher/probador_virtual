import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/environment/environment.dart';

class ProductController {
  List<Product> _productos = [];

  ProductController();

  List<Product> get productos => _productos;

  Future<List<Product>> getProducts() async {
    try {
      final response =
          await http.get(Uri.parse('${Environment.apiUrl}/api/products'));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
      throw Exception(e);
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('${Environment.apiUrl}/api/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('${Environment.apiUrl}/api/products/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }
}
