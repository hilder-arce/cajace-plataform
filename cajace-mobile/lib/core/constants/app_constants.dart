import 'dart:io';

class AppConstants {
  const AppConstants._();

  static const String appName = 'CAJACE Mobile';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const double defaultBorderRadius = 12;
  static const String apiPrefix = '/v1';

  static String get baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:3000$apiPrefix'
      : 'http://localhost:3000$apiPrefix';

  static String get socketBaseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  static String get websocketUrl =>
      Platform.isAndroid ? 'ws://10.0.2.2:3000' : 'ws://localhost:3000';
}
