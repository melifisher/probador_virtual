class RecommendedProduct {
  final int id;
  final String nombre;
  final List<String> talla;
  final List<String> color;
  final double precio;
  final String imagen;
  final bool disponible;
  final String modeloUrl;
  final int categoriaId;
  final double score;
  final String recommendationType; // 'collaborative' o 'content-based'

  RecommendedProduct({
    required this.id,
    required this.nombre,
    required this.talla,
    required this.color,
    required this.precio,
    required this.imagen,
    required this.disponible,
    required this.modeloUrl,
    required this.categoriaId,
    required this.score,
    required this.recommendationType,
  });
}
