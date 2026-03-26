import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../constants/app_constants.dart';
import '../navigation/app_navigator.dart';
import '../session/session_events.dart';
import '../utils/secure_storage.dart';

class ApiClient {
  ApiClient({required AppSecureStorage secureStorage})
      : _secureStorage = secureStorage,
        cookieJar = PersistCookieJar(),
        dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: const <String, String>{'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              await cookieJar.deleteAll();
              await _secureStorage.clearSession();
            } catch (_) {}

            SessionEvents.emitUnauthorized();
            AppNavigator.goToLogin();
          }

          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final CookieJar cookieJar;
  final AppSecureStorage _secureStorage;

  Future<String?> buildCookieHeader(Uri uri) async {
    final cookies = await cookieJar.loadForRequest(uri);
    if (cookies.isEmpty) {
      return null;
    }

    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }
}
