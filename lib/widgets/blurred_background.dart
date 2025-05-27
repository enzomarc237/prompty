import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class BlurredBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double sigmaX;
  final double sigmaY;
  final Color? color;

  const BlurredBackground({
    super.key,
    required this.child,
    this.opacity = 0.8,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color ?? 
        (MacosTheme.of(context).brightness == Brightness.dark 
            ? Colors.black.withOpacity(opacity)
            : Colors.white.withOpacity(opacity));

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: MacosColors.separatorColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.opacity = 0.1,
    this.blur = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity * 0.5),
              ] : [
                Colors.white.withOpacity(opacity + 0.4),
                Colors.white.withOpacity(opacity + 0.2),
              ],
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ModernContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool elevated;

  const ModernContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12.0,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark 
            ? MacosColors.controlBackgroundColor.darkColor.withOpacity(0.9)
            : MacosColors.controlBackgroundColor.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: MacosColors.separatorColor.withOpacity(0.5),
          width: 0.5,
        ),
        boxShadow: elevated ? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: child,
    );
  }
}