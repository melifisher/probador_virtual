import 'dart:convert';
import 'dart:core';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  final int id;
  final String nombre;
  final List<String> talla;
  final List<String> color;
  final double precio;
  final String imagen;
  final bool disponible;
  final String modeloUrl;
  final int categoriaId;

  Product(
      {required this.id,
      required this.nombre,
      required this.talla,
      required this.color,
      required this.precio,
      required this.imagen,
      required this.disponible,
      required this.modeloUrl,
      required this.categoriaId});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'color': color,
        'talla': talla,
        'precio': precio,
        'imagen': imagen,
        'disponible': disponible,
        'modelo_url': modeloUrl,
        'categoria_id': categoriaId
      };
factory Product.fromJson(Map<String, dynamic> json) => Product(
  id: json['id'] is String ? int.parse(json['id']) : json['id'],  // Convertir string a int si es necesario
  nombre: json['nombre'],
  color: (json['color'] as List?)?.map((item) => item.toString()).toList() ?? [],
  talla: (json['talla'] as List?)?.map((item) => item.toString()).toList() ?? [],
  precio: json['precio'] is String ? double.parse(json['precio']) : (json['precio'] as num).toDouble(),
  imagen: json['imagen'] ?? '',
  disponible: json['disponible'] ?? false,
  modeloUrl: json['modelo_url'] ?? '',
  categoriaId: json['categoria_id'] is String ? int.parse(json['categoria_id']) : json['categoria_id'],  // Convertir string a int si es necesario
);
}
