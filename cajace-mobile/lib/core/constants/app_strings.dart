class AppStrings {
  const AppStrings._();

  static const String loginRoute = '/login';
  static const String recoveryRoute = '/recovery';
  static const String dashboardRoute = '/dashboard';
  static const String notificationsRoute = '/notifications';
  static const String sessionsRoute = '/sessions';
  static const String helpRoute = '/help';
  static const String accountRoute = '/account';
  static const String settingsRoute = '/settings';
  static const String dashboardUsersRoute = '/dashboard/users';
  static const String dashboardModulesRoute = '/dashboard/modules';
  static const String dashboardRolesRoute = '/dashboard/roles';
  static const String dashboardPermissionsRoute = '/dashboard/permissions';
}

class LoginStrings {
  const LoginStrings._();

  static const String title = 'Bienvenido a CAJACE';
  static const String subtitle =
      'Inicia sesion para acceder a tu dashboard';
  static const String emailLabel = 'Correo electronico';
  static const String emailHint = 'usuario@empresa.com';
  static const String passwordLabel = 'Contrasena';
  static const String passwordHint = 'Ingresa tu contrasena';
  static const String submitButton = 'Iniciar sesion';
  static const String emailEmptyError = 'Ingresa tu correo.';
  static const String emailInvalidError = 'Correo invalido.';
  static const String passwordEmptyError = 'Ingresa tu contrasena.';
  static const String passwordLengthError = 'Debe tener al menos 6 caracteres.';
}

class DashboardStrings {
  const DashboardStrings._();

  static const String brand = 'CAJACE';
  static const String avatarFallback = 'C';
  static const String badgeOverflow = '9+';
  static const String menuTooltip = 'Menu';
  static const String helpTooltip = 'Ayuda';
  static const String notificationsTooltip = 'Notificaciones';
  static const String profileTooltip = 'Perfil';
  static const String welcomeFallback = 'Usuario';
  static const String roleFallback = 'Sin rol';
  static const String statsRoleLabel = 'Rol asignado';
  static const String statsModulesLabel = 'Modulos';
  static const String statsPermissionsLabel = 'Permisos';
  static const String permissionsTitle = 'Permisos por modulo';
  static const String emptyPermissionsTitle = 'Sin permisos asignados';
  static const String emptyPermissionsMessage =
      'Tu cuenta aun no tiene permisos disponibles en el sistema.';
  static const String logout = 'Cerrar sesion';
  static const String logoutAll = 'Cerrar todas las sesiones';
  static const String loadingProfile = 'Cargando perfil...';
  static const String profileErrorTitle = 'No se pudo cargar el perfil';
  static const String retry = 'Reintentar';
  static const String moduleFallback = 'Sin modulo';
  static const String sessionsHint =
      'Puedes administrar el resto de sesiones desde el panel de sesiones.';
  static const String connectingRealtime =
      'Conectando notificaciones en tiempo real...';
  static const String reconnectingRealtime =
      'Reconectando notificaciones en tiempo real...';
  static const String homeTitle = 'Inicio';
  static const String shortcutTitle = 'Accesos disponibles';
  static const String menuSection = 'Tu espacio';
  static const String noModulesTitle = 'Sin accesos disponibles';
  static const String noModulesMessage =
      'Cuando tu cuenta reciba permisos, veras accesos rapidos aqui.';
  static const String profilePanelGreeting = 'Cuenta activa';
  static const String profilePanelSubtitle =
      'Administra tu cuenta y preferencias del sistema.';
  static const String goodMorning = 'Buenos dias';
  static const String goodAfternoon = 'Buenas tardes';
  static const String goodEvening = 'Buenas noches';
  static const String questionLine = 'Por donde empezamos?';
  static const String drawerTitle = 'Navegacion';
  static const String drawerHome = 'Inicio';
  static const String drawerWorkspace = 'Gestion disponible';
  static const String drawerSupport = 'Soporte';
  static const String chipCreate = 'Puede crear';
  static const String chipRead = 'Puede consultar';
  static const String chipUpdate = 'Puede actualizar';
  static const String chipDelete = 'Puede administrar';
  static const String chipAdmin = 'Rol administrativo';
  static const String chipActive = 'Cuenta activa';
  static const String chipNoCreate = 'Sin creacion';
  static const String chipNoRead = 'Sin lectura';
  static const String chipNoUpdate = 'Sin edicion';
  static const String chipNoDelete = 'Sin gestion';
  static const String realtimeOnline = 'Sincronizacion activa';
  static const String moduleCountSuffix = 'modulos';
  static const String permissionCountSuffix = 'permisos';
  static const String profileButton = 'Mi cuenta';
  static const String settingsButton = 'Configuracion';

  static String greeting(String salutation, String name) => '$salutation, $name';
  static String moduleCount(int total) => '$total $moduleCountSuffix';
  static String permissionCount(int total) => '$total $permissionCountSuffix';
}

class NotificationsStrings {
  const NotificationsStrings._();

  static const String title = 'Notificaciones';
  static const String screenSubtitle =
      'Mantente al dia con alertas de cuenta, roles y sesiones.';
  static const String markAll = 'Marcar todas';
  static const String emptyTitle = 'Sin notificaciones';
  static const String emptySubtitle =
      'Cuando haya actividad en tu cuenta, aparecera aqui.';
  static const String loading = 'Cargando notificaciones...';
  static const String error = 'No se pudieron cargar las notificaciones';
  static const String unknownDate = 'Fecha no disponible';
}

class HelpStrings {
  const HelpStrings._();

  static const String title = 'Ayuda';
  static const String permissionsTitle = 'Que son los permisos?';
  static const String permissionsSubtitle =
      'Los permisos definen que acciones puedes realizar dentro del sistema.';
  static const String roleTitle = 'Que es mi rol?';
  static const String roleSubtitle =
      'Tu rol agrupa un conjunto de permisos asignados por el administrador.';
  static const String notificationsTitle = 'Notificaciones';
  static const String notificationsSubtitle =
      'Recibiras alertas en tiempo real sobre cambios en tu cuenta y sesiones.';
  static const String sessionsTitle = 'Sesiones activas';
  static const String sessionsSubtitle =
      'Puedes cerrar sesiones individuales o todas desde el panel de sesiones.';
  static const String accessTitle = 'Problemas para acceder?';
  static const String accessSubtitle =
      'Usa la opcion Recuperar acceso en la pantalla de login.';
  static const String dynamicSubtitle =
      'Esta guia se adapta al rol y permisos disponibles en tu cuenta.';

  static String dynamicTitle(String name) => 'Ayuda para $name';
}

class ProfilePanelStrings {
  const ProfilePanelStrings._();

  static const String account = 'Mi cuenta';
  static const String settings = 'Configuracion';
  static const String accountName = 'Nombre';
  static const String accountEmail = 'Correo';
  static const String accountRole = 'Rol';
  static const String settingsTitle = 'Preferencias de trabajo';
  static const String notificationsPref = 'Centro de notificaciones';
  static const String notificationsPrefValue =
      'Las alertas en tiempo real se reflejan desde el backend.';
  static const String securityPref = 'Seguridad';
  static const String securityPrefValue =
      'Tu sesion usa cookies seguras y cierre remoto por eventos.';
  static const String sessionPref = 'Sesiones';
  static const String sessionPrefValue =
      'Puedes cerrar la sesion actual o todas las activas.';

  static String settingsMessage(String? role) =>
      'Tu configuracion actual esta alineada con el rol ${role ?? DashboardStrings.roleFallback}.';
}

class DashboardSectionStrings {
  const DashboardSectionStrings._();

  static const String usersTitle = 'Usuarios';
  static const String usersSubtitle = 'Gestion de usuarios y accesos';
  static const String modulesTitle = 'Modulos';
  static const String modulesSubtitle = 'Configuracion de modulos del sistema';
  static const String rolesTitle = 'Roles';
  static const String rolesSubtitle = 'Perfiles y niveles de acceso';
  static const String permissionsTitle = 'Permisos';
  static const String permissionsSubtitle = 'Acciones y privilegios disponibles';
  static const String availableActions = 'Acciones disponibles';
  static const String noAccessTitle = 'Sin acceso operativo';
  static const String canCreate = 'Puede crear';
  static const String canRead = 'Puede consultar';
  static const String canUpdate = 'Puede editar';
  static const String canDelete = 'Puede gestionar';
  static const String noCreate = 'Sin creacion';
  static const String noRead = 'Sin consulta';
  static const String noUpdate = 'Sin edicion';
  static const String noDelete = 'Sin gestion';

  static String noAccessMessage(String module) =>
      'Tu cuenta aun no tiene permisos visibles para $module.';
}
