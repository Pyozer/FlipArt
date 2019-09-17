import 'package:flipart/models/frame.dart';
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final Frame frame;

  const DrawingPainter({this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < frame.points.length - 1; i++) {
      if (frame.points[i] != null && frame.points[i + 1] != null) {
        canvas.drawLine(
          frame.points[i].point,
          frame.points[i + 1].point,
          frame.points[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
