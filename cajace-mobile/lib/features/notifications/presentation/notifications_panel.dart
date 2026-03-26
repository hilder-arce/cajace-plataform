import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/domain/dashboard_models.dart';
import '../../dashboard/presentation/dashboard_provider.dart';

class NotificationsPanel extends ConsumerWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  Text(
                    NotificationsStrings.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const Spacer(),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => _markAllAsRead(context, ref),
                      child: const Text(NotificationsStrings.markAll),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppTheme.border),
            Expanded(
              child: notificationsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _NotificationsEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.leida
                                ? AppTheme.chipBackground
                                : AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconForTipo(item.tipo),
                            size: 18,
                            color: item.leida
                                ? AppTheme.textHint
                                : AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          item.titulo,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: item.leida
                                        ? FontWeight.w400
                                        : FontWeight.w600,
                                  ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.mensaje,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(item.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textHint),
                              ),
                            ],
                          ),
                        ),
                        trailing: item.leida
                            ? null
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () => _markAsRead(context, ref, item),
                      );
                    },
                  );
                },
                loading: () => const _NotificationsLoadingState(),
                error: (error, _) => _NotificationsErrorState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dashboardRepositoryProvider).markAllNotificationsAsRead();
      ref.read(unreadCountProvider.notifier).state = 0;
      ref.invalidate(notificationsProvider);
    } catch (error) {
      _showError(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _markAsRead(
    BuildContext context,
    WidgetRef ref,
    NotificacionItem item,
  ) async {
    if (item.leida) {
      return;
    }

    try {
      await ref.read(dashboardRepositoryProvider).markNotificationAsRead(item.id);
      final notifier = ref.read(unreadCountProvider.notifier);
      notifier.state = notifier.state > 0 ? notifier.state - 1 : 0;
      ref.invalidate(notificationsProvider);
    } catch (error) {
      _showError(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'login':
        return Icons.login;
      case 'nuevo_usuario':
        return Icons.person_add_outlined;
      case 'nuevo_permiso':
        return Icons.key_outlined;
      case 'nuevo_rol':
        return Icons.badge_outlined;
      case 'cambio_rol':
        return Icons.swap_horiz;
      case 'sesion_revocada':
        return Icons.block_outlined;
      case 'cambio_password':
        return Icons.lock_reset_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return NotificationsStrings.unknownDate;
    }

    return DateFormat('dd/MM/yyyy - HH:mm').format(date.toLocal());
  }
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            NotificationsStrings.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsErrorState extends ConsumerWidget {
  const _NotificationsErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              NotificationsStrings.error,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(notificationsProvider),
              child: const Text(DashboardStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.notifications_none_outlined,
            size: 48,
            color: AppTheme.border,
          ),
          const SizedBox(height: 12),
          Text(
            NotificationsStrings.emptyTitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textHint,
                ),
          ),
        ],
      ),
    );
  }
}
