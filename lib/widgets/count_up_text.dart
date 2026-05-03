import 'package:flutter/material.dart';

class CountUpText extends StatefulWidget {
  final String value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.prefix = '',
    this.suffix = '',
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _targetValue;

  @override
  void initState() {
    super.initState();
    _targetValue = _parseValue(widget.value);
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: _targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  double _parseValue(String value) {
    // Remove non-numeric characters like '+' or ','
    final cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanValue) ?? 0;
  }

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _targetValue = _parseValue(widget.value);
      _animation = Tween<double>(begin: _animation.value, end: _targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        String formattedValue;
        if (val >= 1000) {
          formattedValue = (val / 1000).toStringAsFixed(val % 1000 == 0 ? 0 : 1);
          if (formattedValue.endsWith('.0')) {
            formattedValue = formattedValue.substring(0, formattedValue.length - 2);
          }
          // If the original value had a '+' or ',' we might want to preserve some format
          // but for now let's keep it simple or check if original was 10,000+
          if (widget.value.contains(',')) {
            // Simple comma formatting for large numbers if not using 'k' notation
            formattedValue = val.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
          } else {
             formattedValue = val.toInt().toString();
          }
        } else {
          formattedValue = val.toInt().toString();
        }

        return Text(
          '${widget.prefix}$formattedValue${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
