import 'package:flutter/material.dart';

class AppRouteTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration transitionDuration;
  final Curve pushCurve;
  final Curve popCurve;

  AppRouteTransition({
    required this.page,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.pushCurve = Curves.easeOut,
    this.popCurve = Curves.easeIn,
  }) : super(
          transitionDuration: transitionDuration,
          reverseTransitionDuration: transitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final pushAnimation =
                CurvedAnimation(parent: animation, curve: pushCurve);
            final popAnimation =
                CurvedAnimation(parent: secondaryAnimation, curve: popCurve);

            final offsetPush = Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(pushAnimation);

            final offsetPop = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(1.0, 0.0),
            ).animate(popAnimation);

            return SlideTransition(
              position: offsetPush,
              child: SlideTransition(
                position: offsetPop,
                child: FadeTransition(
                  opacity: pushAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}
