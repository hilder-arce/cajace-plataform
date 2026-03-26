import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_navigation.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final wsState = ref.watch(wsProvider);

    return profileAsync.when(
      data: (profile) => _DashboardContent(
        profile: profile,
        unreadCount: unreadCount,
        wsState: wsState,
      ),
      loading: () => const _DashboardLoadingState(),
      error: (error, _) => _DashboardErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.refresh(profileProvider),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.profile,
    required this.unreadCount,
    required this.wsState,
  });

  final UsuarioProfile profile;
  final int unreadCount;
  final WsState wsState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations =
        DashboardNavigationMapper.availableDestinations(profile);
    final highlights =
        DashboardNavigationMapper.highlightPermissions(profile);
    final summary = DashboardNavigationMapper.summarize(
      profile.permisos.values.expand((items) => items).toList(),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      drawer: _DashboardDrawer(profile: profile, destinations: destinations),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              elevation: 0,
              toolbarHeight: 76,
              backgroundColor: AppTheme.backgroundSecondary,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              titleSpacing: 24,
              title: Builder(
                builder: (drawerContext) {
                  return Row(
                    children: <Widget>[
                      _TopIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => Scaffold.of(drawerContext).openDrawer(),
                      ),
                      const Spacer(),
                      Text(
                        DashboardStrings.brand,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          _TopIconButton(
                            icon: Icons.help_outline,
                            onTap: () => context.push(AppStrings.helpRoute),
                          ),
                          const SizedBox(width: 4),
                          _NotificationIcon(
                            unreadCount: unreadCount,
                            onTap: () =>
                                context.push(AppStrings.notificationsRoute),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showProfilePanel(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _initial(profile.nombre),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _HeroCard(profile: profile, highlights: highlights),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.badge_outlined,
                            iconColor: AppTheme.primary,
                            iconBackground: AppTheme.primaryLight,
                            value: profile.rol ?? DashboardStrings.roleFallback,
                            label: DashboardStrings.statsRoleLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.grid_view_outlined,
                            iconColor: AppTheme.violet,
                            iconBackground: AppTheme.violetLight,
                            value: profile.permisos.keys.length.toString(),
                            label: DashboardStrings.statsModulesLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.key_outlined,
                            iconColor: AppTheme.emerald,
                            iconBackground: AppTheme.emeraldLight,
                            value: profile.totalPermisos.toString(),
                            label: DashboardStrings.statsPermissionsLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _RealtimeBanner(wsState: wsState),
                    const SizedBox(height: 24),
                    Text(
                      DashboardStrings.shortcutTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (destinations.isEmpty)
                      const _EmptyCard(
                        icon: Icons.grid_view_outlined,
                        title: DashboardStrings.noModulesTitle,
                        message: DashboardStrings.noModulesMessage,
                      )
                    else
                      ...destinations.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ShortcutCard(
                            destination: item,
                            permissions: DashboardNavigationMapper.permissionsForType(
                              profile,
                              item.type,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      DashboardStrings.permissionsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (profile.permisos.isEmpty)
                      const _EmptyCard(
                        icon: Icons.lock_outline,
                        title: DashboardStrings.emptyPermissionsTitle,
                        message: DashboardStrings.emptyPermissionsMessage,
                      )
                    else
                      ...profile.permisos.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PermissionModuleCard(
                            moduleName: entry.key,
                            permissions: entry.value,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _PermissionChip(
                          label: summary.canCreate
                              ? DashboardStrings.chipCreate
                              : DashboardStrings.chipNoCreate,
                          active: summary.canCreate,
                        ),
                        _PermissionChip(
                          label: summary.canRead
                              ? DashboardStrings.chipRead
                              : DashboardStrings.chipNoRead,
                          active: summary.canRead,
                        ),
                        _PermissionChip(
                          label: summary.canUpdate
                              ? DashboardStrings.chipUpdate
                              : DashboardStrings.chipNoUpdate,
                          active: summary.canUpdate,
                        ),
                        _PermissionChip(
                          label: summary.canDelete
                              ? DashboardStrings.chipDelete
                              : DashboardStrings.chipNoDelete,
                          active: summary.canDelete,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => _logout(context, ref),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text(DashboardStrings.logout),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _logoutAll(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                      ),
                      child: const Text(DashboardStrings.logoutAll),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProfilePanel(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ProfilePanel(profile: profile),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go(AppStrings.loginRoute);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _logoutAll(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).logoutAll();
      if (context.mounted && !ref.read(authProvider).isAuthenticated) {
        context.go(AppStrings.loginRoute);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundPrimary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const Center(
              child: Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 6,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    unreadCount > 9
                        ? DashboardStrings.badgeOverflow
                        : unreadCount.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.backgroundPrimary,
                          fontSize: 9,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({
    required this.profile,
    required this.destinations,
  });

  final UsuarioProfile profile;
  final List<DashboardDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundPrimary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initial(profile.nombre),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(profile.nombre),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                DashboardStrings.drawerTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
              const SizedBox(height: 10),
              _DrawerTile(
                icon: Icons.home_outlined,
                title: DashboardStrings.drawerHome,
                onTap: () {
                  context.pop();
                  context.go(AppStrings.dashboardRoute);
                },
              ),
              const SizedBox(height: 16),
              Text(
                DashboardStrings.drawerWorkspace,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
              const SizedBox(height: 10),
              if (destinations.isEmpty)
                Text(
                  DashboardStrings.noModulesMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                )
              else
                ...destinations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DrawerTile(
                      icon: item.icon,
                      title: item.title,
                      onTap: () {
                        context.pop();
                        context.push(item.route);
                      },
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                DashboardStrings.drawerSupport,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
              const SizedBox(height: 10),
              _DrawerTile(
                icon: Icons.help_outline_rounded,
                title: HelpStrings.title,
                onTap: () {
                  context.pop();
                  context.push(AppStrings.helpRoute);
                },
              ),
              const SizedBox(height: 8),
              _DrawerTile(
                icon: Icons.notifications_none_rounded,
                title: NotificationsStrings.title,
                onTap: () {
                  context.pop();
                  context.push(AppStrings.notificationsRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundSecondary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppTheme.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.profile,
    required this.highlights,
  });

  final UsuarioProfile profile;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DashboardStrings.greeting(_salutation(), profile.nombre),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 17,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            DashboardStrings.questionLine,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 46,
                  height: 1.08,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _PermissionChip(
                label: profile.rol ?? DashboardStrings.roleFallback,
                active: true,
              ),
              ...highlights.map(
                (item) => _PermissionChip(
                  label: item.replaceAll('_', ' '),
                  active: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _salutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return DashboardStrings.goodMorning;
    }
    if (hour < 18) {
      return DashboardStrings.goodAfternoon;
    }
    return DashboardStrings.goodEvening;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RealtimeBanner extends StatelessWidget {
  const _RealtimeBanner({required this.wsState});

  final WsState wsState;

  @override
  Widget build(BuildContext context) {
    final connected = wsState.status == WsConnectionStatus.connected;
    final message = connected
        ? DashboardStrings.realtimeOnline
        : wsState.status == WsConnectionStatus.reconnecting
            ? DashboardStrings.reconnectingRealtime
            : DashboardStrings.connectingRealtime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: connected ? AppTheme.emeraldLight : AppTheme.amberLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              connected ? Icons.cloud_done_outlined : Icons.wifi_tethering_rounded,
              size: 16,
              color: connected ? AppTheme.success : AppTheme.amber,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.destination,
    required this.permissions,
  });

  final DashboardDestination destination;
  final List<String> permissions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundPrimary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.push(destination.route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: destination.iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(destination.icon, color: destination.iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      destination.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: permissions
                          .take(3)
                          .map(
                            (item) => _PermissionChip(
                              label: item.replaceAll('_', ' '),
                              active: false,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionModuleCard extends StatelessWidget {
  const _PermissionModuleCard({
    required this.moduleName,
    required this.permissions,
  });

  final String moduleName;
  final List<String> permissions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  moduleName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  permissions.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.dividerLight),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions
                .map(
                  (item) => _PermissionChip(
                    label: item.replaceAll('_', ' '),
                    active: false,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryLight : AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.primary : AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 30, color: AppTheme.textHint),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.profile});

  final UsuarioProfile profile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initial(profile.nombre),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              DashboardStrings.profilePanelGreeting,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                  ),
            ),
            const SizedBox(height: 4),
            Text(profile.nombre, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              DashboardStrings.profilePanelSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.pop();
                context.push(AppStrings.accountRoute);
              },
              child: const Text(DashboardStrings.profileButton),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                context.pop();
                context.push(AppStrings.settingsRoute);
              },
              child: const Text(DashboardStrings.settingsButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                DashboardStrings.loadingProfile,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: 12),
                Text(
                  DashboardStrings.profileErrorTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text(DashboardStrings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return DashboardStrings.avatarFallback;
  }

  return trimmed.substring(0, 1).toUpperCase();
}
