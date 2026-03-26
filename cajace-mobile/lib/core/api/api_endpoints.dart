class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';
  static const String notificationsUnread = '/notifications/no-leidas';
  static const String notificationsMine = '/notifications/mias';
  static const String notificationsMarkAll = '/notifications/leer-todas';

  static String notificationMarkRead(String id) => '/notifications/$id/leer';
}
