import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/password_recovery_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/domain/dashboard_navigation.dart';
import '../../features/dashboard/presentation/dashboard_section_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/session/presentation/session_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const _StartupScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.loginRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.recoveryRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const PasswordRecoveryScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.dashboardRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.notificationsRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.sessionsRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const SessionScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.helpRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const HelpScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.accountRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const AccountScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.settingsRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppStrings.dashboardUsersRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const DashboardSectionScreen(
            type: DashboardDestinationType.users,
          ),
        ),
      ),
      GoRoute(
        path: AppStrings.dashboardModulesRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const DashboardSectionScreen(
            type: DashboardDestinationType.modules,
          ),
        ),
      ),
      GoRoute(
        path: AppStrings.dashboardRolesRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const DashboardSectionScreen(
            type: DashboardDestinationType.roles,
          ),
        ),
      ),
      GoRoute(
        path: AppStrings.dashboardPermissionsRoute,
        pageBuilder: (context, state) => _buildTransitionPage(
          key: state.pageKey,
          child: const DashboardSectionScreen(
            type: DashboardDestinationType.permissions,
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppStrings.loginRoute;
      final isRecoveryRoute = state.matchedLocation == AppStrings.recoveryRoute;
      final isRootRoute = state.matchedLocation == '/';

      if (isRootRoute) {
        if (isLoading) {
          return null;
        }

        return isAuthenticated
            ? AppStrings.dashboardRoute
            : AppStrings.loginRoute;
      }

      if (!isAuthenticated && !isLoginRoute && !isRecoveryRoute) {
        return AppStrings.loginRoute;
      }

      if (isAuthenticated && (isLoginRoute || isRecoveryRoute)) {
        return AppStrings.dashboardRoute;
      }

      return null;
    },
  );

  AppNavigator.attach(router);
  ref.onDispose(refreshListenable.dispose);
  return router;
});

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

CustomTransitionPage<void> _buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: const Duration(milliseconds: 250),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    },
  );
}
