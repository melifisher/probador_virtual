class DetalleAlquiler {
  final int alquilerId;
  final int productId;
  final int cantidad;
  final double precio;
  final String talla;
  final String color;

  DetalleAlquiler({
    required this.alquilerId,
    required this.productId,
    required this.cantidad,
    required this.precio,
    required this.talla,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'alquiler_id': alquilerId,
      'product_id': productId,
      'cantidad': cantidad,
      'precio': precio,
      'talla': talla,
      'color': color,
    };
  }

  factory DetalleAlquiler.fromMap(Map<String, dynamic> map) {
    return DetalleAlquiler(
      alquilerId: map['alquiler_id'] is String
          ? int.parse(map['alquiler_id'])
          : map['alquiler_id'],
      productId: map['product_id'] is String
          ? int.parse(map['product_id'])
          : map['product_id'],
      cantidad: map['cantidad'] is String
          ? int.parse(map['cantidad'])
          : map['cantidad'],
      precio: map['precio'] is String
          ? double.parse(map['precio'])
          : (map['precio'] as num).toDouble(),
      talla: map['talla'],
      color: map['color'],
    );
  }
}
