import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, success, danger, warning, ghost, outline }
enum ButtonSize { sm, md, lg }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final bool isLoading;
  final bool isDisabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color? textColorOverride;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.fullWidth = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.leftIcon,
    this.rightIcon,
    this.textColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        bgColor = Colors.white;
        textColor = const Color(0xFF374151);
        border = const BorderSide(color: Color(0xFFE5E7EB), width: 2);
        break;
      case ButtonVariant.success:
        bgColor = const Color(0xFF10B981);
        textColor = Colors.white;
        break;
      case ButtonVariant.danger:
        bgColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
      case ButtonVariant.warning:
        bgColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF374151);
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF374151);
        border = BorderSide(color: textColorOverride ?? const Color(0xFFE5E7EB), width: 2);
        break;
    }

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (size) {
      case ButtonSize.sm:
        height = 40;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16);
        break;
      case ButtonSize.md:
        height = 48;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
      case ButtonSize.lg:
        height = 56;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColorOverride ?? textColor,
          elevation: variant == ButtonVariant.ghost || variant == ButtonVariant.outline ? 0 : 2,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size == ButtonSize.sm ? 8 : 12),
            side: border,
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: textColorOverride ?? textColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leftIcon != null) ...[
                    leftIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                  if (rightIcon != null) ...[
                    const SizedBox(width: 8),
                    rightIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
