import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  final int id;
  final String nombre;
  final String descripcion;
  final String talla;
  final double precio;
  final String imagen;
  final bool disponible;
  final String modeloUrl;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.talla,
    required this.precio,
    required this.imagen,
    required this.disponible,
    required this.modeloUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'talla': talla,
        'precio': precio,
        'imagen': imagen,
        'disponible': disponible,
        'modelo_url': modeloUrl,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: int.parse(json['id']),
        nombre: json['nombre'],
        descripcion: json['descripcion'] ?? '',
        talla: json['talla'],
        precio: (json['precio'] as num).toDouble(),
        imagen: json['imagen'] ?? '',
        disponible: json['disponible'],
        modeloUrl: json['modelo_url'] ?? '',
      );
}
