import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'package:sensor/model/particle_data.dart'; // 新しく作成したクラスをインポート

class LiquidPainter extends CustomPainter {
  final List<Body> particles;
  final double particleRadius;
  final double physicsScale;
  final double width;
  final double height;
  final Color defaultLiquidColor; // デフォルトの色

  LiquidPainter({
    required this.particles,
    required this.particleRadius,
    required this.physicsScale,
    required this.width,
    required this.height,
    this.defaultLiquidColor = const Color(0x884FC3F7), // デフォルト色
  });

  @override
  void paint(Canvas canvas, Size size) {
    // メタボール効果のためのオフスクリーンキャンバス
    final recorder = PictureRecorder();
    final offscreenCanvas = Canvas(recorder);

    for (final body in particles) {
      final position = body.position;
      final x = width / 2 + position.x / physicsScale;
      final y = height / 2 + position.y / physicsScale;

      // パーティクルの色を取得
      Color particleColor = defaultLiquidColor;
      if (body.userData is ParticleData) {
        particleColor = (body.userData as ParticleData).color;
      }

      // ブラーペイントを各パーティクルの色で作成
      final blurPaint = Paint()
        ..color = particleColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
        ..style = PaintingStyle.fill;

      // Fixtureのサイズを取得
      double radius = particleRadius;
      if (body.fixtures.isNotEmpty) {
        final fixture = body.fixtures.first;
        if (fixture.shape is CircleShape) {
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

      // パーティクルの色を取得
      Color particleColor = defaultLiquidColor;
      if (body.userData is ParticleData) {
        particleColor = (body.userData as ParticleData).color;
      }

      final paint = Paint()
        ..color = particleColor
        ..style = PaintingStyle.fill;

      // Fixtureのサイズを取得
      double radius = particleRadius;
      if (body.fixtures.isNotEmpty) {
        final fixture = body.fixtures.first;
        if (fixture.shape is CircleShape) {
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
