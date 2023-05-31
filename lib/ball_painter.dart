import 'dart:ui';
import 'package:flutter/material.dart';

class BallPainter extends CustomPainter {
  double ballPositionX;
  double ballPositionY;
  double ballRadius;
  double trailRadius;
  List<Offset> trailPositions;

  BallPainter({
    required this.ballPositionX,
    required this.ballPositionY,
    required this.ballRadius,
    required this.trailPositions,
    required this.trailRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ballPaint = Paint()..color = Colors.blue;
    final trailPaint = Paint()..color = Colors.grey;

    canvas.drawCircle(Offset(ballPositionX, ballPositionY), ballRadius, ballPaint);

    List<Offset> points = trailPositions.map((position) => Offset(position.dx, position.dy)).toList();
    List<double> opacities = List.generate(trailPositions.length, (index) => 1.0 - (index / trailPositions.length));

    trailPaint.color = Colors.grey.withOpacity(0.5);
    canvas.drawPoints(PointMode.points, points, trailPaint);

    for (var i = 0; i < trailPositions.length; i++) {
      trailPaint.color = trailPaint.color.withOpacity(opacities[i]);
      canvas.drawCircle(points[i], trailRadius, trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
