import 'package:flutter/material.dart';

class DrawingPoint {
  Paint paint;
  Offset point;

  DrawingPoint({this.point, this.paint});

  DrawingPoint copy() => DrawingPoint(
        point: Offset(point.dx, point.dy),
        paint: Paint()
          ..color = paint.color
          ..strokeWidth = paint.strokeWidth
          ..isAntiAlias = true,
      );
}
