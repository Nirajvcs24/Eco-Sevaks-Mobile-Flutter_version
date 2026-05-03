import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.6,
    this.borderRadius,
    this.gradientColors,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          // Animated Background Blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final baseColor = widget.gradientColors?[0] ?? const Color(0xFFD1FAE5);
                return Container(
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.9), // Maximum coverage
                  ),
                  child: Stack(
                    children: [
                      _buildBlob(
                        color: baseColor.withValues(alpha: 1.0), // Solid color
                        size: 400,
                        top: -100 + 50 * _controller.value,
                        left: -100 + 50 * (1 - _controller.value),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Glass Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: widget.opacity),
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    double? top,
    double? left,
    double? bottom,
    double? right,
  }) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 50,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
