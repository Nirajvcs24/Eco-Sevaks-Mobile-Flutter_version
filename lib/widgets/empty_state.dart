import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyState({
    super.key,
    this.title = 'No events found',
    this.description = 'Try adjusting your filters or search terms.',
    this.actionText,
    this.onAction,
    this.icon = LucideIcons.search,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: isDark ? const Color(0xFF334155) : Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: actionText!,
                onPressed: onAction!,
                size: ButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

