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
  double trailRadius = 0;

  double dx = 0;
  double dy = 0;

  double maxSpeed = 30;
  double minSpeed = 1;

  double bounceSpeed = 0.8;
  double minBounceSpeed = 0.1;
  double maxBounceSpeed = 2.0;

  List<Offset> trailPositions = [];

  bool isDragging = false;
  Offset dragStartOffset = Offset.zero;
  double dragDistance = 0;

  double maxSpeedSliderValue = 1;
  double bounceSpeedSliderValue = 0.1;

  @override
  void initState() {
    super.initState();
    trailRadius = ballRadius * 0.8;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        ballPositionX = screenWidth / 2;
        ballPositionY = screenHeight / 2;
      });
    });

    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!isDragging) {
        setState(() {
          ballPositionX += dx;
          ballPositionY += dy;

          if (ballPositionX + ballRadius > screenWidth) {
            ballPositionX = screenWidth - ballRadius;
            dx = -dx * bounceSpeed;
          } else if (ballPositionX - ballRadius < 0) {
            ballPositionX = ballRadius;
            dx = -dx * bounceSpeed;
          }

          if (ballPositionY + ballRadius > screenHeight) {
            ballPositionY = screenHeight - ballRadius;
            dy = -dy * bounceSpeed;
          } else if (ballPositionY - ballRadius < 0) {
            ballPositionY = ballRadius;
            dy = -dy * bounceSpeed;
          }

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

          trailPositions.add(Offset(ballPositionX, ballPositionY));

          if (trailPositions.length > 20) {
            trailPositions.removeAt(0);
          }
        });
      }
    });
  }

  void updateBallSpeedOnDrag(DragUpdateDetails details) {
    setState(() {
      dx = details.delta.dx;
      dy = details.delta.dy;

      double scaleFactor = min(dragDistance / 100, 1.0);
      dx *= -scaleFactor;
      dy *= -scaleFactor;
    });
  }

  void onPanStart(DragStartDetails details) {
    setState(() {
      dx = 0;
      dy = 0;
      dragStartOffset = details.localPosition;
      isDragging = true;
    });
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
      dragDistance = 0;
    });
  }

  void showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Max Speed: ${maxSpeed.toStringAsFixed(1)}'),
                  Slider(
                    value: maxSpeedSliderValue,
                    min: 1,
                    max: 40,
                    onChanged: (value) {
                      setState(() {
                        maxSpeedSliderValue = value;
                        maxSpeed = value;
                      });
                    },
                  ),
                  Text('Bounce Speed: ${bounceSpeed.toStringAsFixed(1)}'),
                  Slider(
                    value: bounceSpeedSliderValue,
                    min: 0.1,
                    max: 2.0,
                    onChanged: (value) {
                      setState(() {
                        bounceSpeedSliderValue = value;
                        bounceSpeed = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: (details) {
        updateBallSpeedOnDrag(details);
        dragDistance = (details.localPosition - dragStartOffset).distance;
      },
      onPanEnd: onPanEnd,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bouncing Ball Game'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                showOptionsDialog(context);
              },
            ),
          ],
        ),
        body: CustomPaint(
          painter: BallPainter(
            ballPositionX: ballPositionX,
            ballPositionY: ballPositionY,
            ballRadius: ballRadius,
            trailPositions: trailPositions.reversed.toList(),
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

    canvas.drawCircle(Offset(ballPositionX, ballPositionY), ballRadius, ballPaint);

    for (var i = 0; i < trailPositions.length; i++) {
      double opacity = 1.0 - (i / trailPositions.length);
      trailPaint.color = trailPaint.color.withOpacity(opacity);
      canvas.drawCircle(trailPositions[i], trailRadius, trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
