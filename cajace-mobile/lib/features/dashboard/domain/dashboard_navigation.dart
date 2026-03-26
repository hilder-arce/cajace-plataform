import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import 'dashboard_models.dart';

enum DashboardDestinationType {
  home,
  users,
  modules,
  roles,
  permissions,
}

class DashboardDestination {
  const DashboardDestination({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.route,
    required this.moduleKey,
  });

  final DashboardDestinationType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String route;
  final String moduleKey;
}

class DashboardPermissionSummary {
  const DashboardPermissionSummary({
    required this.canCreate,
    required this.canRead,
    required this.canUpdate,
    required this.canDelete,
  });

  final bool canCreate;
  final bool canRead;
  final bool canUpdate;
  final bool canDelete;

  bool get hasAny => canCreate || canRead || canUpdate || canDelete;
}

class DashboardNavigationMapper {
  const DashboardNavigationMapper._();

  static const List<DashboardDestination> baseDestinations =
      <DashboardDestination>[
    DashboardDestination(
      type: DashboardDestinationType.users,
      title: DashboardSectionStrings.usersTitle,
      subtitle: DashboardSectionStrings.usersSubtitle,
      icon: Icons.people_alt_outlined,
      iconColor: AppTheme.primary,
      iconBackground: AppTheme.primaryLight,
      route: AppStrings.dashboardUsersRoute,
      moduleKey: 'usuarios',
    ),
    DashboardDestination(
      type: DashboardDestinationType.modules,
      title: DashboardSectionStrings.modulesTitle,
      subtitle: DashboardSectionStrings.modulesSubtitle,
      icon: Icons.folder_copy_outlined,
      iconColor: AppTheme.violet,
      iconBackground: AppTheme.violetLight,
      route: AppStrings.dashboardModulesRoute,
      moduleKey: 'modulos',
    ),
    DashboardDestination(
      type: DashboardDestinationType.roles,
      title: DashboardSectionStrings.rolesTitle,
      subtitle: DashboardSectionStrings.rolesSubtitle,
      icon: Icons.badge_outlined,
      iconColor: AppTheme.amber,
      iconBackground: AppTheme.amberLight,
      route: AppStrings.dashboardRolesRoute,
      moduleKey: 'roles',
    ),
    DashboardDestination(
      type: DashboardDestinationType.permissions,
      title: DashboardSectionStrings.permissionsTitle,
      subtitle: DashboardSectionStrings.permissionsSubtitle,
      icon: Icons.key_outlined,
      iconColor: AppTheme.emerald,
      iconBackground: AppTheme.emeraldLight,
      route: AppStrings.dashboardPermissionsRoute,
      moduleKey: 'permisos',
    ),
  ];

  static List<DashboardDestination> availableDestinations(UsuarioProfile user) {
    return baseDestinations.where((destination) {
      return _permissionsForDestination(user, destination).isNotEmpty;
    }).toList();
  }

  static List<String> permissionsForType(
    UsuarioProfile user,
    DashboardDestinationType type,
  ) {
    final destination = baseDestinations.firstWhere(
      (item) => item.type == type,
      orElse: () => baseDestinations.first,
    );
    return _permissionsForDestination(user, destination);
  }

  static DashboardPermissionSummary summarize(List<String> permissions) {
    final normalized = permissions.map((item) => item.toLowerCase()).toList();

    bool hasPrefix(String prefix) {
      return normalized.any((item) => item.startsWith(prefix));
    }

    return DashboardPermissionSummary(
      canCreate: hasPrefix('crear_'),
      canRead: hasPrefix('listar_') || hasPrefix('ver_') || hasPrefix('leer_'),
      canUpdate: hasPrefix('actualizar_') || hasPrefix('editar_'),
      canDelete: hasPrefix('eliminar_') || hasPrefix('restaurar_'),
    );
  }

  static List<String> highlightPermissions(UsuarioProfile user) {
    final permissions = user.permisos.values.expand((items) => items).toList();
    final preferred = permissions.where((permission) {
      final normalized = permission.toLowerCase();
      return normalized.startsWith('crear_') ||
          normalized.startsWith('actualizar_') ||
          normalized.startsWith('eliminar_') ||
          normalized.startsWith('listar_');
    }).toList();

    if (preferred.isNotEmpty) {
      return preferred.take(4).toList();
    }

    return permissions.take(4).toList();
  }

  static List<String> _permissionsForDestination(
    UsuarioProfile user,
    DashboardDestination destination,
  ) {
    final allEntries = user.permisos.entries.toList();
    final byModuleName = allEntries
        .where(
          (entry) =>
              entry.key.toLowerCase().trim() == destination.title.toLowerCase(),
        )
        .expand((entry) => entry.value)
        .toList();

    if (byModuleName.isNotEmpty) {
      return byModuleName;
    }

    return allEntries
        .expand((entry) => entry.value)
        .where(
          (permission) =>
              permission.toLowerCase().contains(destination.moduleKey),
        )
        .toList();
  }
}
