import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance-optimized animation utilities
class AnimationUtils {
  /// Check if reduced motion is preferred for accessibility
  static bool get reduceMotion => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .reduceMotion;

  /// Get adjusted animation duration based on accessibility settings
  static Duration getAnimationDuration(Duration baseDuration) {
    if (reduceMotion) {
      return Duration.zero;
    }
    return baseDuration;
  }

  /// Create a performance-optimized staggered animation
  static Widget createStaggeredList({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (reduceMotion) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  /// Create a performance-optimized slide transition
  static Widget createSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (reduceMotion) {
      return child;
    }

    return SlideTransition(
      position: animation.drive(
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }

  /// Create a performance-optimized scale transition
  static Widget createScaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    if (reduceMotion) {
      return child;
    }

    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }

  /// Create a performance-optimized fade transition
  static Widget createFadeTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    if (reduceMotion) {
      return child;
    }

    return FadeTransition(
      opacity: animation.drive(
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }

  /// Create a hero animation with performance optimizations
  static Widget createHeroAnimation({
    required String tag,
    required Widget child,
    Duration flightDuration = const Duration(milliseconds: 300),
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return Material(
              type: MaterialType.transparency,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
      child: child,
    );
  }

  /// Create a performance-optimized shimmer effect
  static Widget createShimmerEffect({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (reduceMotion) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor ?? Colors.grey[300]!,
                highlightColor ?? Colors.grey[100]!,
                baseColor ?? Colors.grey[300]!,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Optimized list animation controller
  static Widget createOptimizedListAnimation({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 50),
    Duration itemDuration = const Duration(milliseconds: 300),
  }) {
    if (reduceMotion) {
      return Column(children: children);
    }

    return Column(
      children: children.asMap().entries.map((entry) {
        final child = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: itemDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

/// Performance monitoring for animations
class AnimationPerformanceMonitor {
  static int _frameCount = 0;
  static DateTime? _lastFrameTime;
  static double _currentFPS = 60.0;

  /// Initialize performance monitoring
  static void initialize() {
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  static void _onFrame(Duration timestamp) {
    _frameCount++;
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _currentFPS = 1000 / frameDuration.inMilliseconds;
    }

    _lastFrameTime = now;
  }

  /// Get current FPS
  static double get currentFPS => _currentFPS;

  /// Check if performance is good (> 55 FPS)
  static bool get isPerformanceGood => _currentFPS > 55;

  /// Get performance recommendations
  static List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    if (_currentFPS < 30) {
      recommendations.add('Consider reducing animation complexity');
      recommendations.add('Enable reduced motion in accessibility settings');
    } else if (_currentFPS < 45) {
      recommendations.add('Consider shorter animation durations');
    }

    return recommendations;
  }
}

/// Custom curves for enhanced animations
class UssdCurves {
  static const Curve enterEasing = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve exitEasing = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve standardEasing = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve accelerateEasing = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve decelerateEasing = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve sharpEasing = Cubic(0.4, 0.0, 0.6, 1.0);
}
