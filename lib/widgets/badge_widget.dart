import 'package:flutter/material.dart';

enum BadgeVariant {
  primary,
  secondary,
  accent,
  success,
  warning,
  danger,
  gray,
  dark,
}

enum BadgeSize { sm, md, lg }

class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final BadgeSize size;
  final Widget? icon;
  final bool showDot;
  final bool glow;

  const BadgeWidget({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.md,
    this.icon,
    this.showDot = false,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color dotColor;

    switch (variant) {
      case BadgeVariant.primary:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        dotColor = const Color(0xFF10B981);
        break;
      case BadgeVariant.secondary:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        dotColor = const Color(0xFFF59E0B);
        break;
      case BadgeVariant.accent:
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF075985);
        dotColor = const Color(0xFF0EA5E9);
        break;
      case BadgeVariant.success:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        dotColor = const Color(0xFF10B981);
        break;
      case BadgeVariant.warning:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        dotColor = const Color(0xFFF59E0B);
        break;
      case BadgeVariant.danger:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        dotColor = const Color(0xFFEF4444);
        break;
      case BadgeVariant.gray:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF1F2937);
        dotColor = const Color(0xFF6B7280);
        break;
      case BadgeVariant.dark:
        bgColor = const Color(0xFF111827);
        textColor = Colors.white;
        dotColor = Colors.white;
        break;
    }

    double fontSize;
    EdgeInsets padding;
    double gap;

    switch (size) {
      case BadgeSize.sm:
        fontSize = 11;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
        gap = 4;
        break;
      case BadgeSize.md:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
        gap = 6;
        break;
      case BadgeSize.lg:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
        gap = 8;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: gap),
          ],
          if (icon != null) ...[
            icon!,
            SizedBox(width: gap),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  factory BadgeWidget.status(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return BadgeWidget(
          label: status[0].toUpperCase() + status.substring(1),
          variant: BadgeVariant.success,
          showDot: true,
          glow: true,
        );
      case 'pending':
        return BadgeWidget(
          label: 'Pending',
          variant: BadgeVariant.warning,
          showDot: true,
        );
      case 'restricted':
      case 'rejected':
        return BadgeWidget(
          label: status[0].toUpperCase() + status.substring(1),
          variant: BadgeVariant.danger,
          showDot: true,
        );
      default:
        return BadgeWidget(
          label: status[0].toUpperCase() + status.substring(1),
          variant: BadgeVariant.gray,
          showDot: true,
        );
    }
  }
}
