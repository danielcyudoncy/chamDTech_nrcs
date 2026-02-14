import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/app/config/theme_config.dart';

enum AppButtonStyle { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(context, theme),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    switch (style) {
      case AppButtonStyle.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? ThemeConfig.primaryColor,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _buildContent(Colors.white),
        );
      case AppButtonStyle.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? (isDark ? Colors.grey[800] : Colors.grey[200]),
            foregroundColor: textColor ?? (isDark ? Colors.white : ThemeConfig.textPrimary),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _buildContent(isDark ? Colors.white : ThemeConfig.textPrimary),
        );
      case AppButtonStyle.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? ThemeConfig.primaryColor),
            foregroundColor: textColor ?? (color ?? ThemeConfig.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _buildContent(color ?? ThemeConfig.primaryColor),
        );
      case AppButtonStyle.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? (color ?? ThemeConfig.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _buildContent(color ?? ThemeConfig.primaryColor),
        );
    }
  }

  Widget _buildContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );
  }
}
