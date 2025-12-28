import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/providers/theme_provider.dart';
import 'package:focusflow/widgets/gradient_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final taskService = context.watch<TaskService>();
    final focusService = context.watch<FocusService>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = userService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedTasks = taskService.tasks.where((t) => t.isCompleted).length;
    final totalTasks = taskService.tasks.length;
    final focusMinutes = focusService.getTotalFocusMinutes();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                child: GradientContainer(
                  colors: isDark
                    ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                    : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                  borderRadius: BorderRadius.circular(60),
                  child: Center(
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'G',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Guest User',
                style: context.textStyles.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'guest@focusflow.app',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: AppSpacing.horizontalXl,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.task_alt,
                        value: '$completedTasks',
                        label: 'Completed',
                        color: isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pending_actions,
                        value: '${totalTasks - completedTasks}',
                        label: 'Pending',
                        color: isDark ? DarkModeColors.darkTertiary : LightModeColors.lightTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        value: '$focusMinutes',
                        label: 'Focus (min)',
                        color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: AppSpacing.horizontalXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) => themeProvider.toggleTheme(),
                            ),
                          ),
                          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                          _SettingsTile(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            subtitle: 'Manage your notifications',
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notifications settings coming soon')),
                              );
                            },
                          ),
                          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                          _SettingsTile(
                            icon: Icons.help,
                            title: 'Help & Support',
                            subtitle: 'Get help with the app',
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Help center coming soon')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: _SettingsTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        titleColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(true),
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await context.read<UserService>().logout();
                            if (context.mounted) context.go('/login');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: 2),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
    title: Text(
      title,
      style: context.textStyles.titleMedium?.copyWith(
        color: titleColor,
        fontWeight: FontWeight.w500,
      ),
    ),
    subtitle: subtitle != null
      ? Text(subtitle!, style: context.textStyles.bodySmall)
      : null,
    trailing: trailing,
    onTap: onTap,
  );
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.timer_rounded,
              label: 'Focus',
              isSelected: currentIndex == 1,
              onTap: () => context.go('/focus'),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
