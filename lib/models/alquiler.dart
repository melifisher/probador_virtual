class Alquiler {
  final int id;
  final int usuarioId;
  final int prendaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double costoTotal;
  final String estado; // 'pendiente', 'activo', 'completado', 'cancelado'

  Alquiler({
    required this.id,
    required this.usuarioId,
    required this.prendaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.costoTotal,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'prendaId': prendaId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'costoTotal': costoTotal,
      'estado': estado,
    };
  }

  factory Alquiler.fromMap(Map<String, dynamic> map) {
    return Alquiler(
      id: map['id'],
      usuarioId: map['usuarioId'],
      prendaId: map['prendaId'],
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaFin: DateTime.parse(map['fechaFin']),
      costoTotal: map['costoTotal'],
      estado: map['estado'],
    );
  }
}
