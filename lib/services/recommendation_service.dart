import 'package:http/http.dart' as http;
import 'package:probador_virtual/controllers/product_controller.dart';
import 'package:probador_virtual/models/alquiler.dart';
import 'package:probador_virtual/models/detalle_alquiler.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/recommended_product.dart';
import '../config/environment/environment.dart';
import 'dart:math' as math;
import '../controllers/alquiler_controller.dart';
import '../controllers/detalle_alquiler_controller.dart';
//import '../controllers/product_controller.dart';

class UserRating {
  final int userId;
  final int productId;
  final double rating;

  UserRating({
    required this.userId,
    required this.productId,
    required this.rating,
  });
}

class RecommendationService {
  final String baseUrl = Environment.apiUrl;
  AlquilerController alquilerController = AlquilerController();
  DetalleAlquilerController detalleAlquilerController =
      DetalleAlquilerController();
  ProductController productController = ProductController();

  // Add caching mechanism
  final _cache = <String, dynamic>{};
  final _cacheExpiration = const Duration(hours: 1);

  RecommendationService();

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
    final cacheKey = 'recommendations:$userId';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      // Get initial recommendations from backend
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        print('Initial recommendations: $productsJson');
        return productsJson.map((json) => Product.fromJson(json)).toList();

        // Get user ratings for Pearson correlation
        /* final userRatings = await _getUserRatings(userId);
        print('User ratings: $userRatings');
        // Calculate similarity scores using Pearson
        final recommendations =
            await _enhanceWithPearsonScores(productsJson, userRatings, userId);
        print('Enhanced recommendations: $recommendations');
        _cache[cacheKey] = recommendations;
        print('Cache: $_cache');


        return recommendations; */
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Content based');
      return _getContentBasedRecommendations(userId);
    }
  }

  Future<List<UserRating>> _getUserRatings(int userId) async {
    final rentals = await alquilerController.getAlquileres(userId);
    return _convertRentalsToRatings(rentals);
  }

  Future<List<RecommendedProduct>> _enhanceWithPearsonScores(
      List<dynamic> products, List<UserRating> userRatings, int userId) async {
    List<RecommendedProduct> enhancedProducts = [];

    for (var product in products) {
      // Get ratings from other users for this product
      final productRatings = await _getProductRatings(product['id']);

      // Calculate Pearson correlation
      double pearsonScore =
          _calculatePearsonCorrelation(userRatings, productRatings);

      // Combine backend score with Pearson score
      double finalScore =
          _combineScores(baseScore: 1.0, pearsonScore: pearsonScore);

      enhancedProducts.add(RecommendedProduct(
        id: product['id'],
        nombre: product['nombre'],
        precio: product['precio'].toDouble(),
        disponible: product['disponible'],
        imagen: product['imagen'],
        modeloUrl: product['modelo_url'],
        color: List<String>.from(product['color']),
        talla: List<String>.from(product['talla']),
        categoriaId: product['categoriaId'],
        score: finalScore,
        recommendationType: 'hybrid_pearson',
      ));
    }

    // Sort by final score
    enhancedProducts.sort((a, b) => b.score.compareTo(a.score));
    return enhancedProducts;
  }

  double _combineScores({
    required double baseScore,
    required double pearsonScore,
  }) {
    const pearsonWeight = 0.3;
    const baseWeight = 0.7;

    return (baseScore * baseWeight) + (pearsonScore * pearsonWeight);
  }

  Future<List<UserRating>> _getProductRatings(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId/ratings'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> ratings = json.decode(response.body);
      return ratings
          .map((r) => UserRating(
                userId: r['user_id'],
                productId: productId,
                rating: r['rating'].toDouble(),
              ))
          .toList();
    }

    return [];
  }

  Future<List<RecommendedProduct>> _getCollaborativeRecommendations(
      int userId) async {
    // 1. Obtener historial de alquileres de todos los usuarios
    final allRentals = await alquilerController.getAlquileres(null);
    print('All Rentals: $allRentals');
    // 2. Convertir alquileres a ratings
    final userRatings = await _convertRentalsToRatings(allRentals);

    // 3. Encontrar usuarios similares
    final similarUsers = await _findSimilarUsers(userId, userRatings);

    // 4. Obtener productos recomendados basados en usuarios similares
    return await _getRecommendationsFromSimilarUsers(
        userId, similarUsers, userRatings);
  }

  Future<List<Map<String, dynamic>>> _getAllUsersRentals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/rentals'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener historial de alquileres');
    }
  }

  Future<List<UserRating>> _convertRentalsToRatings(
      List<Alquiler> rentals) async {
    List<UserRating> ratings = [];

    for (var rental in rentals) {
      final userId = rental.usuarioId;
      final detalles =
          await detalleAlquilerController.getDetallesAlquiler(rental.id);

      // Convertir frecuencia de alquiler y recompra en un rating
      for (var detalle in detalles) {
        final productId = detalle.productId;

        // Calcular rating basado en:
        // - Frecuencia de alquiler del producto
        // - Si el usuario ha alquilado el producto múltiples veces
        // - Estado del alquiler (completado, devuelto a tiempo, etc.)
        double rating = _calculateImplicitRating(rental, detalle);

        ratings.add(UserRating(
          userId: userId,
          productId: productId,
          rating: rating,
        ));
      }
    }

    return ratings;
  }

  double _calculateImplicitRating(Alquiler rental, DetalleAlquiler detalle) {
    double rating = 3.0; // Rating base

    // Aumentar rating si:
    // - El usuario ha alquilado el mismo producto múltiples veces
    if (detalle.cantidad > 1) {
      rating += 1.0;
    }

    // - El alquiler fue completado exitosamente
    if (rental.estado == 'completado') {
      rating += 0.5;
    }

    // - El producto fue devuelto a tiempo
    /* final fechaDevolucion = DateTime.parse(rental['fecha_devolucion']);
    final fechaReserva = DateTime.parse(rental['fecha_reserva']);
    if (fechaDevolucion.isBefore(fechaReserva)) {
      rating += 0.5;
    } */

    return math.min(5.0, rating); // Máximo rating de 5.0
  }

  Future<List<Map<String, double>>> _findSimilarUsers(
    int userId,
    List<UserRating> allRatings,
  ) async {
    // Obtener ratings del usuario actual
    final userRatings = allRatings.where((r) => r.userId == userId).toList();

    // Calcular similitud con otros usuarios usando correlación de Pearson
    Map<int, double> similarities = {};
    final otherUserIds = allRatings.map((r) => r.userId).toSet()
      ..remove(userId);

    for (var otherId in otherUserIds) {
      final otherRatings =
          allRatings.where((r) => r.userId == otherId).toList();

      // Encontrar productos calificados por ambos usuarios
      final commonProducts = userRatings
          .map((r) => r.productId)
          .toSet()
          .intersection(otherRatings.map((r) => r.productId).toSet());

      if (commonProducts.isEmpty) continue;

      // Calcular correlación de Pearson
      double similarity = _calculatePearsonCorrelation(
        userRatings.where((r) => commonProducts.contains(r.productId)).toList(),
        otherRatings
            .where((r) => commonProducts.contains(r.productId))
            .toList(),
      );

      if (similarity > 0) {
        similarities[otherId] = similarity;
      }
    }

    // Ordenar usuarios por similitud y tomar los top 5
    final sortedUsers = similarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedUsers
        .take(5)
        .map((e) => {'userId': e.key.toDouble(), 'similarity': e.value})
        .toList();
  }

  double _calculatePearsonCorrelation(
    List<UserRating> ratings1,
    List<UserRating> ratings2,
  ) {
    if (ratings1.isEmpty || ratings2.isEmpty) return 0;

    // Calcular medias
    double mean1 =
        ratings1.map((r) => r.rating).reduce((a, b) => a + b) / ratings1.length;
    double mean2 =
        ratings2.map((r) => r.rating).reduce((a, b) => a + b) / ratings2.length;

    // Calcular numerador y denominadores
    double numerator = 0;
    double denominator1 = 0;
    double denominator2 = 0;

    for (int i = 0; i < ratings1.length; i++) {
      double diff1 = ratings1[i].rating - mean1;
      double diff2 = ratings2[i].rating - mean2;

      numerator += diff1 * diff2;
      denominator1 += diff1 * diff1;
      denominator2 += diff2 * diff2;
    }

    if (denominator1 == 0 || denominator2 == 0) return 0;

    return numerator / (math.sqrt(denominator1) * math.sqrt(denominator2));
  }

  Future<List<RecommendedProduct>> _getRecommendationsFromSimilarUsers(
    int userId,
    List<Map<String, double>> similarUsers,
    List<UserRating> allRatings,
  ) async {
    // Obtener productos que el usuario actual no ha alquilado
    final userRentedProducts = allRatings
        .where((r) => r.userId == userId)
        .map((r) => r.productId)
        .toSet();

    // Calcular predicciones de ratings para productos no alquilados
    Map<int, double> predictions = {};

    for (var rating in allRatings) {
      if (userRentedProducts.contains(rating.productId)) continue;

      final userSimilarity = similarUsers.firstWhere(
            (u) => u['userId'] == rating.userId,
            orElse: () => {'similarity': 0.0},
          )['similarity'] ??
          0.0;

      if (userSimilarity > 0) {
        predictions[rating.productId] = (predictions[rating.productId] ?? 0.0) +
            rating.rating * userSimilarity;
      }
    }

    // Normalizar predicciones
    for (var productId in predictions.keys) {
      final totalSimilarity = similarUsers
          .map((u) => u['similarity'])
          .reduce((a, b) => (a ?? 0.0) + (b ?? 0.0));
      predictions[productId] =
          (predictions[productId] ?? 0.0) / totalSimilarity!;
    }

    // Obtener detalles de los productos recomendados
    final recommendedProducts = await _getProductDetails(predictions);

    // Ordenar por predicción de rating
    recommendedProducts.sort((a, b) => b.score.compareTo(a.score));

    return recommendedProducts.take(10).toList();
  }

  Future<List<RecommendedProduct>> _getProductDetails(
    Map<int, double> predictions,
  ) async {
    List<RecommendedProduct> recommendations = [];

    for (var entry in predictions.entries) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/${entry.key}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final product = json.decode(response.body);
        recommendations.add(RecommendedProduct(
          id: product['id'],
          nombre: product['nombre'],
          precio: product['precio'].toDouble(),
          disponible: product['disponible'],
          imagen: product['imagen'],
          modeloUrl: product['modeloUrl'],
          color: List<String>.from(product['color']),
          talla: List<String>.from(product['talla']),
          categoriaId: product['categoriaId'],
          score: entry.value,
          recommendationType: 'collaborative',
        ));
      }
    }

    return recommendations;
  }

  void _cleanCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final cacheTime = value['cacheTime'] as DateTime;
      return now.difference(cacheTime) > _cacheExpiration;
    });
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
