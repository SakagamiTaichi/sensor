import 'package:flutter/material.dart'; // Colorクラスのために追加
import 'package:forge2d/forge2d.dart';

class LiquidSimulatorState {
  final World world;
  final List<Body> particles;
  final Vector2? accelerometer;
  final double width;
  final double height;
  final Color currentColor; // 現在選択されている色を追加

  static const double particleRadius = 6.0;
  static const int particleCount = 10;
  static const double elasticity = 0.3;
  static const double physicsScale = 0.02;
  static const double particleDensity = 0.8;
  static const double particleFriction = 0.1;

  const LiquidSimulatorState({
    required this.world,
    this.particles = const [],
    this.accelerometer,
    this.width = 0,
    this.height = 0,
    // デフォルトの色を半透明の水色に設定
    this.currentColor = const Color(0x884FC3F7),
  });

  // copyWithメソッドに色情報を追加
  LiquidSimulatorState copyWith({
    World? world,
    List<Body>? particles,
    Vector2? accelerometer,
    double? width,
    double? height,
    Color? currentColor,
  }) {
    return LiquidSimulatorState(
      world: world ?? this.world,
      particles: particles ?? this.particles,
      accelerometer: accelerometer ?? this.accelerometer,
      width: width ?? this.width,
      height: height ?? this.height,
      currentColor: currentColor ?? this.currentColor,
    );
  }
}
