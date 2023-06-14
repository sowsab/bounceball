import 'package:flutter/material.dart';
import 'bouncing_ball_game.dart';

class BouncingBallApp extends StatelessWidget {
  const BouncingBallApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncing Ball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BouncingBallGame(),
    );
  }
}