import 'package:flutter/material.dart';
import '../utils/design_system.dart';

/// Modern page transition with slide and fade effects
class ModernPageTransition extends PageRouteBuilder {
  final Widget child;
  final String? heroTag;
  
  ModernPageTransition({
    required this.child,
    this.heroTag,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from right to left
            final slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            // Fade transition
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            // Scale transition for the previous page (exit)
            final scaleAnimation = Tween<double>(
              begin: 1.0,
              end: 0.95,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: UssdDesignSystem.animationMedium,
          reverseTransitionDuration: UssdDesignSystem.animationMedium,
        );
}

/// Shared element transition for hero animations
class SharedElementTransition extends StatelessWidget {
  final String heroTag;
  final Widget child;
  
  const SharedElementTransition({
    Key? key,
    required this.heroTag,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Slide up transition for bottom sheets and modals
class SlideUpTransition extends PageRouteBuilder {
  final Widget child;
  final bool isFullScreen;
  
  SlideUpTransition({
    required this.child,
    this.isFullScreen = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: UssdDesignSystem.animationMedium,
          reverseTransitionDuration: UssdDesignSystem.animationFast,
          opaque: isFullScreen,
          barrierDismissible: !isFullScreen,
          barrierColor: Colors.black54,
        );
}

/// Scale transition for modals and dialogs
class ScaleTransition extends PageRouteBuilder {
  final Widget child;
  
  ScaleTransition({
    required this.child,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: UssdDesignSystem.curveDefault,
              ),
            );

            return Transform.scale(
              scale: scaleAnimation.value,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: UssdDesignSystem.animationFast,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
        );
}

/// Fade transition for simple page changes
class FadePageTransition extends PageRouteBuilder {
  final Widget child;
  
  FadePageTransition({
    required this.child,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: UssdDesignSystem.animationMedium,
        );
}

/// Custom transition helper methods
class PageTransitions {
  static ModernPageTransition slideFromRight<T>(Widget page) {
    return ModernPageTransition(child: page);
  }
  
  static SlideUpTransition slideFromBottom<T>(Widget page, {bool isFullScreen = false}) {
    return SlideUpTransition(child: page, isFullScreen: isFullScreen);
  }
  
  static ScaleTransition scaleUp<T>(Widget page) {
    return ScaleTransition(child: page);
  }
  
  static FadePageTransition fadeIn<T>(Widget page) {
    return FadePageTransition(child: page);
  }
}