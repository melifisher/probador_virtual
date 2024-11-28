class Cart {
  final int id;
  final int userId;
  final int productId;
  final int cantidad;
  final String talla;
  final String color;
  final int rentalDays;
   final String nombre;  
  final double precio;   
  final String imagen;   
  

  Cart({
    required this.id,
    required this.userId,
    required this.productId,
    required this.cantidad,
    required this.talla,
    required this.color,
    required this.rentalDays,
     required this.nombre,    
    required this.precio,    
    required this.imagen,     
  });

  // Convierte un Cart a un Map para enviar al backend
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'cantidad': cantidad,
      'talla': talla,
      'color': color,
      'rental_days': rentalDays,
      'nombre':nombre,
      'precio': precio,
      'imagen':imagen,
    };
  }

  // Crea un Cart desde un Map recibido del backend
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] != null && map['id'] is String ? int.parse(map['id']) : (map['id'] ?? 0),
      userId: map['user_id'] != null && map['user_id'] is String ? int.parse(map['user_id']) : (map['user_id'] ?? 0),
      productId: map['product_id'] != null && map['product_id'] is String ? int.parse(map['product_id']) : (map['product_id'] ?? 0),
      cantidad: map['cantidad'] != null && map['cantidad'] is String ? int.parse(map['cantidad']) : (map['cantidad'] ?? 1),
      talla: map['talla'] ?? 'Talla no especificada',
      color: map['color'] ?? 'Color no especificado',
      rentalDays: map['rental_days'] != null && map['rental_days'] is String
          ? int.parse(map['rental_days'])
          : (map['rental_days'] ?? 1),
      nombre: map['nombre'] ?? 'Producto sin nombre',    
      precio: map['precio'] != null && map['precio'] is String 
          ? double.parse(map['precio']) 
          : (map['precio'] ?? 0.0),    
      imagen: map['imagen'] ?? 'URL no disponible',   
    );
  }
}
