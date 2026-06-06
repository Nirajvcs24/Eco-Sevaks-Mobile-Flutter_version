import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isVisible) setState(() => _isVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isVisible) setState(() => _isVisible = true);
          }
          return false;
        },
        child: widget.child,
      ),
      bottomNavigationBar: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white.withValues(alpha: 0.6),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2), 
                      width: 1
                    )
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: LucideIcons.home,
                      label: 'Home',
                      isActive: location == '/',
                      onTap: () => context.go('/'),
                    ),
                    _NavItem(
                      icon: LucideIcons.calendar,
                      label: 'Events',
                      isActive: location == '/events',
                      onTap: () => context.go('/events'),
                    ),
                    _CenterNavItem(
                      icon: LucideIcons.plusCircle,
                      label: 'Create',
                      isActive: location == '/create-event',
                      onTap: () => context.go('/create-event'),
                    ),
                    if (user?.role == 'admin')
                      _NavItem(
                        icon: LucideIcons.shield,
                        label: 'Admin',
                        isActive: location == '/admin',
                        onTap: () => context.go('/admin'),
                      )
                    else
                      _NavItem(
                        icon: LucideIcons.layoutDashboard,
                        label: 'Dashboard',
                        isActive: location == '/dashboard',
                        onTap: () => context.go('/dashboard'),
                      ),
                    _NavItem(
                      icon: LucideIcons.user,
                      label: 'Profile',
                      isActive: location == '/profile',
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark ? Colors.white : AppColors.primary;
    final Color inactiveColor = isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive 
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD1FAE5)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive 
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.primary),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive 
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

