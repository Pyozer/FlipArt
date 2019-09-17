import 'package:flipart/models/frame.dart';
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final Frame frame;
  final bool isTransparent;

  const DrawingPainter({@required this.frame, this.isTransparent = false});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < frame.points.length - 1; i++) {
      if (frame.points[i] != null && frame.points[i + 1] != null) {
        Paint pointPaint = frame.points[i].paint;
        if (isTransparent) {
          pointPaint = Paint()
            ..color = pointPaint.color.withOpacity(0.2)
            ..strokeWidth = pointPaint.strokeWidth
            ..isAntiAlias = true;
        }
        
        canvas.drawLine(
          frame.points[i].point,
          frame.points[i + 1].point,
          pointPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
