import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            icon: isDark ? LucideIcons.moon : LucideIcons.sun,
            title: 'Dark Mode',
            subtitle: 'Toggle between light and dark themes',
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (value) => themeProvider.toggleTheme(),
              activeThumbColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Account'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            icon: LucideIcons.user,
            title: 'Profile Settings',
            subtitle: 'Update your personal information',
            onTap: () {
              // TODO: Implement profile edit
            },
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.bell,
            title: 'Notifications',
            subtitle: 'Manage your alert preferences',
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 16),
          _buildSettingTile(
            context,
            icon: LucideIcons.info,
            title: 'Help Center',
            subtitle: 'FAQs and support',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.fileText,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Eco-Sevaks v1.0.0',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? Icon(LucideIcons.chevronRight, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

