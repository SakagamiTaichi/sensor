// ボールを描画するためのカスタムペインター
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

class BallPainter extends CustomPainter {
  final Body? ballBody;
  final double ballRadius;
  final double physicsScale;
  final double width;
  final double height;

  BallPainter({
    required this.ballBody,
    required this.ballRadius,
    required this.physicsScale,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ballBody == null) return;

    final position = ballBody!.position;

    // 物理座標から画面座標に変換
    final x = width / 2 + position.x / physicsScale;
    final y = height / 2 + position.y / physicsScale;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // シンプルなボールの描画
    canvas.drawCircle(
      Offset(x, y),
      ballRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(BallPainter oldDelegate) {
    return ballBody != oldDelegate.ballBody;
  }
}
