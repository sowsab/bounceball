import 'package:flutter/material.dart';
import 'dart:async';

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

  double dx = 5; // 공의 X축 이동 속도
  double dy = 5; // 공의 Y축 이동 속도

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        // 공의 위치를 업데이트하고 경계 체크
        ballPositionX += dx;
        ballPositionY += dy;

        if (ballPositionX + ballRadius > screenWidth || ballPositionX - ballRadius < 0) {
          dx = -dx;
        }

        if (ballPositionY + ballRadius > screenHeight || ballPositionY - ballRadius < 0) {
          dy = -dy;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bouncing Ball Game'),
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              left: ballPositionX - ballRadius,
              top: ballPositionY - ballRadius,
              child: Container(
                width: ballRadius * 2,
                height: ballRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}