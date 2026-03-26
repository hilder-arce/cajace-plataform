import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/dashboard_navigation.dart';
import 'dashboard_provider.dart';

class DashboardSectionScreen extends ConsumerWidget {
  const DashboardSectionScreen({
    required this.type,
    super.key,
  });

  final DashboardDestinationType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wsProvider);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        final destination = DashboardNavigationMapper.baseDestinations
            .firstWhere((item) => item.type == type);
        final permissions = DashboardNavigationMapper.permissionsForType(
          profile,
          type,
        );
        final summary = DashboardNavigationMapper.summarize(permissions);

        return Scaffold(
          backgroundColor: AppTheme.backgroundSecondary,
          appBar: AppBar(
            title: Text(destination.title),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: destination.iconBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          destination.icon,
                          color: destination.iconColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        destination.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        destination.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildStatusChips(context, summary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DashboardSectionStrings.availableActions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                if (permissions.isEmpty)
                  _SectionEmptyCard(
                    title: DashboardSectionStrings.noAccessTitle,
                    message: DashboardSectionStrings.noAccessMessage(
                      destination.title,
                    ),
                  )
                else
                  ...permissions.map(
                    (permission) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundPrimary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: destination.iconBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                destination.icon,
                                size: 18,
                                color: destination.iconColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatPermission(permission),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const _SectionLoadingState(),
      error: (error, _) => _SectionErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }

  List<Widget> _buildStatusChips(
    BuildContext context,
    DashboardPermissionSummary summary,
  ) {
    final chips = <Widget>[
      _StatusChip(
        label: summary.canCreate
            ? DashboardSectionStrings.canCreate
            : DashboardSectionStrings.noCreate,
        active: summary.canCreate,
      ),
      _StatusChip(
        label: summary.canRead
            ? DashboardSectionStrings.canRead
            : DashboardSectionStrings.noRead,
        active: summary.canRead,
      ),
      _StatusChip(
        label: summary.canUpdate
            ? DashboardSectionStrings.canUpdate
            : DashboardSectionStrings.noUpdate,
        active: summary.canUpdate,
      ),
      _StatusChip(
        label: summary.canDelete
            ? DashboardSectionStrings.canDelete
            : DashboardSectionStrings.noDelete,
        active: summary.canDelete,
      ),
    ];

    return chips;
  }

  String _formatPermission(String value) {
    return value.replaceAll('_', ' ');
  }
}

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wsProvider);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        final topActions = DashboardNavigationMapper.highlightPermissions(profile);
        final helpItems = <_InfoTileData>[
          const _InfoTileData(
            icon: Icons.shield_outlined,
            title: HelpStrings.permissionsTitle,
            subtitle: HelpStrings.permissionsSubtitle,
            iconColor: AppTheme.primary,
            background: AppTheme.primaryLight,
          ),
          const _InfoTileData(
            icon: Icons.badge_outlined,
            title: HelpStrings.roleTitle,
            subtitle: HelpStrings.roleSubtitle,
            iconColor: AppTheme.violet,
            background: AppTheme.violetLight,
          ),
          const _InfoTileData(
            icon: Icons.notifications_outlined,
            title: HelpStrings.notificationsTitle,
            subtitle: HelpStrings.notificationsSubtitle,
            iconColor: AppTheme.emerald,
            background: AppTheme.emeraldLight,
          ),
          const _InfoTileData(
            icon: Icons.devices_outlined,
            title: HelpStrings.sessionsTitle,
            subtitle: HelpStrings.sessionsSubtitle,
            iconColor: AppTheme.amber,
            background: AppTheme.amberLight,
          ),
          const _InfoTileData(
            icon: Icons.lock_outline,
            title: HelpStrings.accessTitle,
            subtitle: HelpStrings.accessSubtitle,
            iconColor: AppTheme.error,
            background: AppTheme.primaryLight,
          ),
        ];

        return Scaffold(
          backgroundColor: AppTheme.backgroundSecondary,
          appBar: AppBar(title: const Text(HelpStrings.title)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        HelpStrings.dynamicTitle(profile.nombre),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        HelpStrings.dynamicSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: topActions
                            .map((item) => _StatusChip(label: item, active: true))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...helpItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoTile(item: item),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _SectionLoadingState(),
      error: (error, _) => _SectionErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }
}

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wsProvider);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) => Scaffold(
        backgroundColor: AppTheme.backgroundSecondary,
        appBar: AppBar(title: const Text(ProfilePanelStrings.account)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const <BoxShadow>[AppTheme.cardShadow],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _safeInitial(profile.nombre),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.nombre,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _StatusChip(
                      label: profile.rol ?? DashboardStrings.roleFallback,
                      active: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionDetailTile(
                title: ProfilePanelStrings.accountName,
                value: profile.nombre,
              ),
              const SizedBox(height: 12),
              _SectionDetailTile(
                title: ProfilePanelStrings.accountEmail,
                value: profile.email,
              ),
              const SizedBox(height: 12),
              _SectionDetailTile(
                title: ProfilePanelStrings.accountRole,
                value: profile.rol ?? DashboardStrings.roleFallback,
              ),
            ],
          ),
        ),
      ),
      loading: () => const _SectionLoadingState(),
      error: (error, _) => _SectionErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wsProvider);
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) => Scaffold(
        backgroundColor: AppTheme.backgroundSecondary,
        appBar: AppBar(title: const Text(ProfilePanelStrings.settings)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              _SectionInfoCard(
                title: ProfilePanelStrings.settingsTitle,
                message: ProfilePanelStrings.settingsMessage(profile.rol),
                icon: Icons.tune_outlined,
                iconColor: AppTheme.violet,
                background: AppTheme.violetLight,
              ),
              const SizedBox(height: 16),
              _SectionDetailTile(
                title: ProfilePanelStrings.notificationsPref,
                value: ProfilePanelStrings.notificationsPrefValue,
              ),
              const SizedBox(height: 12),
              _SectionDetailTile(
                title: ProfilePanelStrings.securityPref,
                value: ProfilePanelStrings.securityPrefValue,
              ),
              const SizedBox(height: 12),
              _SectionDetailTile(
                title: ProfilePanelStrings.sessionPref,
                value: ProfilePanelStrings.sessionPrefValue,
              ),
            ],
          ),
        ),
      ),
      loading: () => const _SectionLoadingState(),
      error: (error, _) => _SectionErrorState(
        message: error.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }
}

class _SectionInfoCard extends StatelessWidget {
  const _SectionInfoCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDetailTile extends StatelessWidget {
  const _SectionDetailTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionLoadingState extends StatelessWidget {
  const _SectionLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _SectionErrorState extends StatelessWidget {
  const _SectionErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.error,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.lock_outline, color: AppTheme.textHint),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
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
        border: Border.all(
          color: active ? AppTheme.primaryLight : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _InfoTileData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[AppTheme.cardShadow],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTileData {
  const _InfoTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color background;
}

String _safeInitial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return DashboardStrings.avatarFallback;
  }

  return trimmed.substring(0, 1).toUpperCase();
}
