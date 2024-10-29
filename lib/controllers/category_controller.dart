import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';
import '../config/environment/environment.dart';

class CategoryController {
  CategoryController();

  Future<List<Category>> getCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${Environment.apiUrl}/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        return productsJson.map((json) => Category.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error loading categories: $e');
      throw Exception(e);
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final response =
          await http.get(Uri.parse('${Environment.apiUrl}/api/categories/$id'));
      if (response.statusCode == 200) {
        final dynamic categoryJson = json.decode(response.body);
        return Category.fromMap(categoryJson);
      } else {
        throw Exception('Failed to load category');
      }
    } catch (e) {
      print('Error loading category: $e');
      throw Exception(e);
    }
  }

  Future<Category> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}/api/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toMap()),
    );
    if (response.statusCode == 201) {
      return Category.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Category> updateCategory(Category category) async {
    final response = await http.put(
      Uri.parse('${Environment.apiUrl}/api/categories/${category.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toMap()),
    );
    if (response.statusCode == 200) {
      return Category.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http
        .delete(Uri.parse('${Environment.apiUrl}/api/categories/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
          Uri.parse('${Environment.apiUrl}/api/products/category/$categoryId'));
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        //print('Productos JSON: $productsJson');
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
      throw Exception(e);
    }
  }
}
