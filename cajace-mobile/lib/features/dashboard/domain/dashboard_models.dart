class UsuarioProfile {
  const UsuarioProfile({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.permisos,
    required this.estado,
    required this.createdAt,
  });

  final String id;
  final String nombre;
  final String email;
  final String? rol;
  final Map<String, List<String>> permisos;
  final bool estado;
  final DateTime createdAt;

  int get totalPermisos =>
      permisos.values.fold<int>(0, (sum, items) => sum + items.length);

  factory UsuarioProfile.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> parsePermisos(dynamic rawPermisos) {
      if (rawPermisos is! Map<String, dynamic>) {
        return const <String, List<String>>{};
      }

      return rawPermisos.map(
        (key, value) => MapEntry(
          key.toString(),
          value is List
              ? value.map((item) => item.toString()).toList()
              : const <String>[],
        ),
      );
    }

    return UsuarioProfile(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      rol: json['rol']?.toString(),
      permisos: parsePermisos(json['permisos']),
      estado: json['estado'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class NotificacionItem {
  const NotificacionItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime createdAt;

  factory NotificacionItem.fromJson(Map<String, dynamic> json) {
    return NotificacionItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      leida: json['leida'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
