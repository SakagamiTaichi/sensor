// liquid.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

class LiquidPainter extends CustomPainter {
  final List<Body> particles;
  final double particleRadius;
  final double physicsScale;
  final double width;
  final double height;
  final Color liquidColor;

  LiquidPainter({
    required this.particles,
    required this.particleRadius,
    required this.physicsScale,
    required this.width,
    required this.height,
    this.liquidColor = const Color(0x884FC3F7), // 半透明の水色
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 通常の粒子描画
    final paint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;

    // メタボール効果のためのオフスクリーンキャンバス
    final recorder = PictureRecorder();
    final offscreenCanvas = Canvas(recorder);
    final blurPaint = Paint()
      ..color = liquidColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
      ..style = PaintingStyle.fill;

    for (final body in particles) {
      final position = body.position;
      // 物理座標から画面座標に変換
      final x = width / 2 + position.x / physicsScale;
      final y = height / 2 + position.y / physicsScale;

      offscreenCanvas.drawCircle(
        Offset(x, y),
        particleRadius * 1.2, // ブラー効果のため少し大きく
        blurPaint,
      );
    }

    // ブラーエフェクトを適用した画像を描画
    final picture = recorder.endRecording();
    final image = picture.toImage(size.width.toInt(), size.height.toInt());

    // 通常の描画
    for (final body in particles) {
      final position = body.position;
      final x = width / 2 + position.x / physicsScale;
      final y = height / 2 + position.y / physicsScale;

      canvas.drawCircle(
        Offset(x, y),
        particleRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return true; // 毎フレーム再描画
  }
}
