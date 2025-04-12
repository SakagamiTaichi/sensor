// liquid.dart (修正部分)
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

      // Fixtureのサイズを取得
      double radius = particleRadius;
      if (body.fixtures.isNotEmpty) {
        final fixture = body.fixtures.first;
        if (fixture.shape is CircleShape) {
          // 物理スケールに基づいて実際の描画半径を計算
          radius = (fixture.shape as CircleShape).radius / physicsScale;
        }
      }

      // ブラー効果のため少し大きく描画
      offscreenCanvas.drawCircle(
        Offset(x, y),
        radius * 1.2,
        blurPaint,
      );
    }

    // 通常の描画
    for (final body in particles) {
      final position = body.position;
      final x = width / 2 + position.x / physicsScale;
      final y = height / 2 + position.y / physicsScale;

      // Fixtureのサイズを取得
      double radius = particleRadius;
      if (body.fixtures.isNotEmpty) {
        final fixture = body.fixtures.first;
        if (fixture.shape is CircleShape) {
          // 物理スケールに基づいて実際の描画半径を計算
          radius = (fixture.shape as CircleShape).radius / physicsScale;
        }
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return true; // 毎フレーム再描画
  }
}
