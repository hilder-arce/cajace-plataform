import 'package:go_router/go_router.dart';

import '../constants/app_strings.dart';

class AppNavigator {
  const AppNavigator._();

  static GoRouter? _router;

  static void attach(GoRouter router) {
    _router = router;
  }

  static void goToLogin() {
    _router?.go(AppStrings.loginRoute);
  }
}
