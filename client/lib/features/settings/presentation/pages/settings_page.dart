import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text('Profile', style: AppTextStyles.heading2),
          const SizedBox(height: AppSizes.md),

          // Profile Card
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: user.isAuthenticated
                      ? Text(
                          user.displayName[0].toUpperCase(),
                          style: AppTextStyles.heading2.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: colorScheme.onPrimaryContainer,
                        ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: AppTextStyles.subtitle),
                      const SizedBox(height: 2),
                      Text(
                        user.isGuest
                            ? 'Sign in to unlock all features'
                            : user.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.isGuest)
                  FilledButton(
                    onPressed: () => context.pushNamed('login'),
                    child: const Text('Sign In'),
                  )
                else
                  OutlinedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // Settings sections
          Text(
            'Preferences',
            style: AppTextStyles.label.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: 'English',
          ),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            trailing: 'System',
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            trailing: 'On',
          ),

          const SizedBox(height: AppSizes.lg),

          Text(
            'About',
            style: AppTextStyles.label.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About Jeong',
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Feedback',
          ),

          const SizedBox(height: AppSizes.lg),

          Center(
            child: Text(
              'Jeong v1.0.0',
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(title, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () {},
    );
  }
}
