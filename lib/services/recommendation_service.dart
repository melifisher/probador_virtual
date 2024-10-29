import 'package:http/http.dart' as http;
import 'package:probador_virtual/controllers/product_controller.dart';
import 'package:probador_virtual/models/alquiler.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/recommended_product.dart';
import '../config/environment/environment.dart';
import '../controllers/alquiler_controller.dart';
import '../controllers/detalle_alquiler_controller.dart';

class RecommendationService {
  final String baseUrl = Environment.apiUrl;
  AlquilerController alquilerController = AlquilerController();
  DetalleAlquilerController detalleAlquilerController =
      DetalleAlquilerController();
  ProductController productController = ProductController();

  final _cache = <String, dynamic>{};
  final _cacheExpiration = const Duration(hours: 1);
  final int
      type; //0=basado en productos similares, 1=basado en usuarios similares

  RecommendationService({required this.type});

  Future<Map<String, dynamic>> getFullProductDetails(int productId) async {
    final cacheKey = 'product:$productId:full';

    // Check local cache
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId/full'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cache[cacheKey] = data;
        return data;
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Error getting product details: $e');
    }
  }

  Future<List<Product>> getRecommendations(int userId) async {
    final cacheKey = 'recommendations:$userId:$type';
    final now = DateTime.now();

    if (_cache.containsKey(cacheKey)) {
      final cacheData = _cache[cacheKey];
      final cacheTime = cacheData['timestamp'] as DateTime;
      if (now.difference(cacheTime) < _cacheExpiration) {
        return cacheData['data'] as List<Product>;
      } else {
        _cache.remove(cacheKey);
      }
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/$userId/$type'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        print('Initial recommendations: $productsJson');
        final products =
            productsJson.map((json) => Product.fromJson(json)).toList();
        // Guardar en caché
        _cache[cacheKey] = {
          'data': products,
          'timestamp': now,
        };

        return products;
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      final fallbackProducts = await _getContentBasedRecommendations(userId);

      _cache[cacheKey] = {
        'data': fallbackProducts,
        'timestamp': now,
      };

      return fallbackProducts;
    }
  }

  // Método de recomendaciones basadas en contenido
  Future<List<Product>> _getContentBasedRecommendations(int userId) async {
    try {
      // 1. Obtener historial de alquileres del usuario
      final userHistory = await alquilerController.getAlquileres(userId);

      // 2. Obtener preferencias del usuario basadas en su historial
      final userPreferences = await _analyzeUserPreferences(userHistory);

      // 3. Obtener productos similares basados en las preferencias
      return await _getSimilarProducts(userPreferences);
    } catch (e) {
      throw Exception('Error al obtener recomendaciones: $e');
    }
  }

  Future<Map<String, dynamic>> _analyzeUserPreferences(
      List<Alquiler> history) async {
    // Análisis de preferencias del usuario
    Map<String, int> categoryCount = {};
    Map<String, int> colorCount = {};
    Map<String, int> sizeCount = {};

    for (var rental in history) {
      final detalles =
          await detalleAlquilerController.getDetallesAlquiler(rental.id);
      for (var detalle in detalles) {
        // Contabilizar categorías
        final product = await productController.getProduct(detalle.productId);
        final categoryId = product.categoriaId;
        categoryCount[categoryId.toString()] =
            (categoryCount[categoryId.toString()] ?? 0) + 1;

        // Contabilizar color
        final color = detalle.color;
        colorCount[color] = (colorCount[color] ?? 0) + 1;

        // Contabilizar talla
        final talla = detalle.talla;
        sizeCount[talla] = (sizeCount[talla] ?? 0) + 1;
      }
    }

    // Normalizar conteos a porcentajes
    return {
      'categories': _normalizePreferences(categoryCount),
      'colors': _normalizePreferences(colorCount),
      'sizes': _normalizePreferences(sizeCount),
    };
  }

  Map<String, double> _normalizePreferences(Map<String, int> counts) {
    final total = counts.values.reduce((a, b) => a + b);
    return counts.map((key, value) => MapEntry(key, value / total));
  }

  Future<List<Product>> _getSimilarProducts(
      Map<String, dynamic> preferences) async {
    // Obtener productos disponibles
    final products = await productController.getProductsDisponibles(null);

    // Calcular score para cada producto basado en preferencias
    List<RecommendedProduct> recommendedProducts = [];

    for (var product in products) {
      double score = _calculateProductScore(product, preferences);

      if (score > 0.5) {
        // Umbral mínimo de similitud
        recommendedProducts.add(RecommendedProduct(
          id: product.id,
          nombre: product.nombre,
          precio: product.precio.toDouble(),
          disponible: product.disponible,
          imagen: product.imagen,
          modeloUrl: product.modeloUrl,
          color: List<String>.from(product.color),
          talla: List<String>.from(product.talla),
          categoriaId: product.categoriaId,
          score: score,
          recommendationType: 'content-based',
        ));
      }
    }

    // Ordenar por score descendente
    recommendedProducts.sort((a, b) => b.score.compareTo(a.score));

    // Retornar top 10 recomendaciones
    List<Product> resultProducts =
        recommendedProducts.take(10).map((recommendedProduct) {
      return Product(
        id: recommendedProduct.id,
        nombre: recommendedProduct.nombre,
        precio: recommendedProduct.precio,
        disponible: recommendedProduct.disponible,
        imagen: recommendedProduct.imagen,
        modeloUrl: recommendedProduct.modeloUrl,
        color: List<String>.from(recommendedProduct.color),
        talla: List<String>.from(recommendedProduct.talla),
        categoriaId: recommendedProduct.categoriaId,
      );
    }).toList();
    return resultProducts;
  }

  double _calculateProductScore(
      Product product, Map<String, dynamic> preferences) {
    double score = 0.0;

    // Peso para cada factor
    const categoryWeight = 0.4;
    const colorWeight = 0.3;
    const sizeWeight = 0.3;

    // Score por categoría
    final categoryPref =
        preferences['categories'][product.categoriaId.toString()] ?? 0.0;
    score += categoryPref * categoryWeight;

    // Score por color
    double colorScore = 0.0;
    for (var color in product.color) {
      colorScore += preferences['colors'][color] ?? 0.0;
    }
    score += (colorScore / product.color.length) * colorWeight;

    // Score por talla
    double sizeScore = 0.0;
    for (var talla in product.talla) {
      sizeScore += preferences['sizes'][talla] ?? 0.0;
    }
    score += (sizeScore / product.talla.length) * sizeWeight;

    return score;
  }
}
