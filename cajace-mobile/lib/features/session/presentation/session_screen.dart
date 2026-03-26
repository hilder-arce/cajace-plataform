import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/cajace_button.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserModel> _loadProfile() async {
    try {
      return await ref.read(authRepositoryProvider).getProfile();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _logoutAll() async {
    await ref.read(authProvider.notifier).logoutAll();
    if (mounted && !ref.read(authProvider).isAuthenticated) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sesion actual')),
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudo cargar la sesion actual.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return Center(
                child: Text(
                  'No hay informacion de sesion disponible.',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usuario'),
                  subtitle: Text(user.name),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Correo'),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Roles'),
                  subtitle: Text(
                    user.roles.isEmpty
                        ? 'Sin roles asignados'
                        : user.roles.join(', '),
                  ),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Dispositivo'),
                  subtitle: Text('Pendiente de implementacion'),
                ),
                const SizedBox(height: 24),
                CajaceButton(
                  label: 'Cerrar todas las sesiones',
                  isOutlined: true,
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _logoutAll,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
