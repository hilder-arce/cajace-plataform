import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CajaceButton extends StatefulWidget {
  const CajaceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Widget? icon;

  @override
  State<CajaceButton> createState() => _CajaceButtonState();
}

class _CajaceButtonState extends State<CajaceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLoading || widget.onPressed == null;

    final indicatorColor =
        widget.isOutlined ? AppTheme.primary : AppTheme.backgroundPrimary;

    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.isLoading)
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
        if (widget.isLoading) const SizedBox(width: 12),
        if (!widget.isLoading && widget.icon != null) widget.icon!,
        if (!widget.isLoading && widget.icon != null) const SizedBox(width: 8),
        Text(widget.label),
      ],
    );

    final button = widget.isOutlined
        ? OutlinedButton(
            onPressed: isDisabled ? null : widget.onPressed,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isDisabled ? null : widget.onPressed,
            child: buttonChild,
          );

    final sizedButton = widget.isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;

    return Listener(
      onPointerDown: isDisabled ? null : (_) => _setPressed(true),
      onPointerUp: isDisabled ? null : (_) => _setPressed(false),
      onPointerCancel: isDisabled ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: sizedButton,
      ),
    );
  }
}
