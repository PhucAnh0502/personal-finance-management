import 'package:flutter/material.dart';
import 'package:pmf_app/core/theme/app_theme.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isConvex;
  final Color? baseColor;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.borderRadius,
    this.padding,
    this.isConvex = false,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = baseColor ?? AppTheme.getSurfaceColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
            offset: const Offset(2, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}