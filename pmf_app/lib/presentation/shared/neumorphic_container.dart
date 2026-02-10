import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';

class NeumorphicContainer extends StatefulWidget{
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isConvex;
  final Color baseColor;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.borderRadius,
    this.padding,
    this.isConvex = false,
    this.baseColor = AppColors.surface,
  });

  @override
  State<NeumorphicContainer> createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.baseColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        boxShadow: widget.isConvex
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  offset: const Offset(-6, -6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: const Offset(6, 6),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
            ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  offset: const Offset(-4, -4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: widget.child,
    );
  }
}