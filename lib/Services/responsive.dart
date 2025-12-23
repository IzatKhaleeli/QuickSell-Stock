import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;

  late final double _scale;

  Responsive(this.context, {this.baseWidth = 400}) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    const minScale = 0.7;
    const maxScale = 1.3;
    _scale = (shortestSide / baseWidth).clamp(minScale, maxScale);
  }

  double scale(double value) => value * _scale;
  double get factor => _scale;

  double font(double size) => scale(size);

  double get safeHeight {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.top - mq.padding.bottom;
  }

  double get safeHeightWithBottomNav {
    final mq = MediaQuery.of(context);
    return mq.size.height -
        mq.padding.top -
        mq.padding.bottom -
        kBottomNavigationBarHeight;
  }
}
