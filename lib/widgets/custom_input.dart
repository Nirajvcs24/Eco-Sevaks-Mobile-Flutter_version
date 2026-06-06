import 'package:flutter/material.dart';


class CustomInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? leftIcon;
  final String? errorText;
  final String? helperText;
  final bool required;
  final int maxLines;
  final Function(String)? onChanged;

  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.leftIcon,
    this.errorText,
    this.helperText,
    this.required = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            label: widget.required
                ? Text.rich(
                    TextSpan(
                      text: widget.label,
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                : null,
            labelText: widget.required ? null : widget.label,
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: widget.leftIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: widget.leftIcon,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            errorText: widget.errorText,
            contentPadding: EdgeInsets.fromLTRB(
              widget.leftIcon != null ? 0 : 16,
              24,
              16,
              8,
            ),
          ),
        ),
        if (widget.helperText != null && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.helperText!,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
            ),
          ),
      ],
    );
  }
}

