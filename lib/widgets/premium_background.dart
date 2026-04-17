import 'package:flutter/material.dart';
import 'dart:ui';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showGlassOverlay;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showGlassOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Background
        Container(
          color: colorScheme.surface,
        ),
        
        // Animated/Static Aura Glows
        Positioned(
          top: -100,
          right: -50,
          child: _AuraCircle(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            size: 400,
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _AuraCircle(
            color: colorScheme.secondary.withValues(alpha: isDark ? 0.12 : 0.08),
            size: 350,
          ),
        ),
        if (isDark)
          Positioned(
            top: 200,
            left: -50,
            child: _AuraCircle(
              color: colorScheme.tertiary.withValues(alpha: 0.08),
              size: 300,
            ),
          ),

        // Optional Glassmorphism Overlay for content isolation
        if (showGlassOverlay)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: colorScheme.surface.withValues(alpha: isDark ? 0.4 : 0.4),
              ),
            ),
          ),

        // The actual content
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}

class _AuraCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _AuraCircle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
