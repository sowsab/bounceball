import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(BouncingBallApp());

class BouncingBallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncing Ball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BouncingBallGame(),
    );
  }
}

class BouncingBallGame extends StatefulWidget {
  @override
  _BouncingBallGameState createState() => _BouncingBallGameState();
}

class _BouncingBallGameState extends State<BouncingBallGame> {
  double ballPositionX = 10;
  double ballPositionY = 10;
  double ballRadius = 10;
  double screenWidth = 0;
  double screenHeight = 0;
  double trailRadius = 0; // 흔적의 반지름

  double dx = 0; // 공의 X축 이동 속도
  double dy = 0; // 공의 Y축 이동 속도

  double maxSpeed = 35; // 최대 속도
  double minSpeed = 1;

  List<Offset> trailPositions = []; // 흔적 위치들

  @override
  void initState() {
    super.initState();
    trailRadius = ballRadius; // ballRadius 값을 trailRadius로 지정
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        // 공의 위치를 업데이트하고 경계 체크
        ballPositionX += dx;
        ballPositionY += dy;

        if (ballPositionX + ballRadius > screenWidth) {
          ballPositionX = screenWidth - ballRadius; // 가장자리에서 멈추지 않고 반대 방향으로 이동
          dx = -dx * 0.8;
        } else if (ballPositionX - ballRadius < 0) {
          ballPositionX = ballRadius; // 가장자리에서 멈추지 않고 반대 방향으로 이동
          dx = -dx * 0.8;
        }

        if (ballPositionY + ballRadius > screenHeight) {
          ballPositionY = screenHeight - ballRadius; // 가장자리에서 멈추지 않고 반대 방향으로 이동
          dy = -dy * 0.8;
        } else if (ballPositionY - ballRadius < 0) {
          ballPositionY = ballRadius; // 가장자리에서 멈추지 않고 반대 방향으로 이동
          dy = -dy * 0.8;
        }

        // 최대 속도 제한
        if (dx.abs() > maxSpeed) {
          dx = dx.sign * maxSpeed;
        }

        if (dy.abs() > maxSpeed) {
          dy = dy.sign * maxSpeed;
        }

        if (dx.abs() < minSpeed) {
          dx = dx.sign * minSpeed;
        }

        if (dy.abs() < minSpeed) {
          dy = dy.sign * minSpeed;
        }

        // 흔적 위치 업데이트
        trailPositions.add(Offset(ballPositionX, ballPositionY));

        // 흔적 위치 제한
        if (trailPositions.length > 20) {
          trailPositions.removeAt(0);
        }
      });
    });
  }

  void updateBallSpeedOnDrag(DragUpdateDetails details) {
    setState(() {
      // 드래그 방향과 반대 방향으로 속도 설정
      dx = -details.delta.dx;
      dy = -details.delta.dy;

      // 최대 속도 제한
      double speed = sqrt(dx * dx + dy * dy);
      if (speed > maxSpeed) {
        double scaleFactor = maxSpeed / speed;
        dx *= scaleFactor;
        dy *= scaleFactor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanUpdate: updateBallSpeedOnDrag,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bouncing Ball Game'),
        ),
        body: CustomPaint(
          painter: BallPainter(
            ballPositionX: ballPositionX,
            ballPositionY: ballPositionY,
            ballRadius: ballRadius,
            trailPositions: trailPositions,
            trailRadius: trailRadius,
          ),
        ),
      ),
    );
  }
}

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

    // 공 그리기
    canvas.drawCircle(Offset(ballPositionX, ballPositionY), ballRadius, ballPaint);

    // 흔적 그리기
    for (var i = 0; i < trailPositions.length; i++) {
      canvas.drawCircle(trailPositions[i], trailRadius, trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}