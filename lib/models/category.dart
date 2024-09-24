class Category {
  final int id;
  final String nombre;

  Category({
    required this.id,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: int.parse(map['id']),
      nombre: map['nombre'],
    );
  }
}
