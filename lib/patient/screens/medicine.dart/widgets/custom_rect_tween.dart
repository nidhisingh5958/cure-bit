import 'dart:ui';
import 'package:flutter/widgets.dart';

class CustomRectTween extends RectTween {
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    final beginRect = begin ?? Rect.zero;
    final endRect = end ?? Rect.zero;

    return Rect.fromLTRB(
      lerpDouble(beginRect.left, endRect.left, elasticCurveValue) ?? 0,
      lerpDouble(beginRect.top, endRect.top, elasticCurveValue) ?? 0,
      lerpDouble(beginRect.right, endRect.right, elasticCurveValue) ?? 0,
      lerpDouble(beginRect.bottom, endRect.bottom, elasticCurveValue) ?? 0,
    );
  }
}
