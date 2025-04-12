// liquid_simulator_state.dart
import 'package:forge2d/forge2d.dart';

class LiquidSimulatorState {
  final World world;
  final List<Body> particles;
  final Vector2? accelerometer;
  final double width;
  final double height;

  static const double particleRadius = 6.0;
  static const int particleCount = 10;
  static const double elasticity = 0.3;
  static const double physicsScale = 0.02;
  static const double particleDensity = 0.8; // 水の密度
  static const double particleFriction = 0.1; // 水の摩擦係数

  const LiquidSimulatorState({
    required this.world,
    this.particles = const [],
    this.accelerometer,
    this.width = 0,
    this.height = 0,
  });

  // 新しい状態を作成するコピーメソッド
  LiquidSimulatorState copyWith({
    World? world,
    List<Body>? particles,
    Vector2? accelerometer,
    double? width,
    double? height,
  }) {
    return LiquidSimulatorState(
      world: world ?? this.world,
      particles: particles ?? this.particles,
      accelerometer: accelerometer ?? this.accelerometer,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
