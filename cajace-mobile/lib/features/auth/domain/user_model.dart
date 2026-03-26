class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.roles,
    required this.permissions,
  });

  final String id;
  final String email;
  final String name;
  final List<String> roles;
  final List<String> permissions;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }

      return const <String>[];
    }

    List<String> parsePermissions(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value.values
            .whereType<List>()
            .expand((items) => items.map((item) => item.toString()))
            .toList();
      }

      return parseStringList(value);
    }

    List<String> parseRoles(Map<String, dynamic> payload) {
      final explicitRoles = parseStringList(payload['roles']);
      if (explicitRoles.isNotEmpty) {
        return explicitRoles;
      }

      final role = payload['rol'];
      if (role != null && role.toString().isNotEmpty) {
        return <String>[role.toString()];
      }

      return const <String>[];
    }

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['nombre'] ?? json['fullName'] ?? '')
          .toString(),
      roles: parseRoles(json),
      permissions: parsePermissions(json['permisos'] ?? json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'roles': roles,
      'permissions': permissions,
    };
  }
}
