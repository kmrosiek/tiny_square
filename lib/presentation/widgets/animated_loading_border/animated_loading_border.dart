import 'package:flutter/material.dart';
import 'package:tiny_square/presentation/consts/homepage_contants.dart';
import 'package:tiny_square/presentation/widgets/animated_loading_border/widgets/animated_border_painter.dart';
import 'package:tiny_square/presentation/widgets/animated_loading_border/widgets/infinite_progress_builder.dart';

class AnimatedLoadingBorder extends StatelessWidget {
  const AnimatedLoadingBorder({
    super.key,
    required this.isLoading,
    required this.borderColor,
    this.child,
    this.borderRadius = 16.0,
    this.strokeWidth = 3.0,
  });

  final bool isLoading;
  final Color borderColor;
  final Widget? child;
  final double borderRadius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InfiniteProgressBuilder(
        duration: HomepageConstants.loadingBorderFullCircleDuration,
        isActive: isLoading,
        builder: (context, progress) {
          return TweenAnimationBuilder<double>(
            tween: Tween(end: isLoading ? 1.0 : 0.0),
            duration: HomepageConstants.loadingBorderFadeOutDuration,
            curve: Curves.easeOut,
            builder: (context, borderOpacity, child) {
              return CustomPaint(
                painter: AnimatedBorderPainter(
                  progress: progress,
                  color: borderColor,
                  opacity: borderOpacity,
                  borderRadius: borderRadius,
                  strokeWidth: strokeWidth,
                ),
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.all(strokeWidth),
              child: ClipRRect(borderRadius: BorderRadius.circular(borderRadius - strokeWidth / 2), child: child),
            ),
          );
        },
      ),
    );
  }
}
