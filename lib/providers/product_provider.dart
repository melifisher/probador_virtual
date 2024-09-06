import 'package:get/get.dart';
import '../config/environment/environment.dart';
import '../models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductProvider extends GetConnect {
  String url = Environment.apiUrl;

  Future<List<Product>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await get('$url/api/products');

    if (response.status.hasError) {
      throw Exception('Error fetching products: ${response.statusText}');
    }
    List<Product> products = List<Product>.from(
        response.body.map((product) => Product.fromJson(product)));
    return products;
  }
}
