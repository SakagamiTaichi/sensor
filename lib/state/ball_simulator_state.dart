// ball_simulator_provider.dart
import 'package:forge2d/forge2d.dart';

// シミュレーションの状態を表すクラス
class BallSimulatorState {
  final World world;
  final Body? ballBody;
  final Vector2? accelerometer;
  final double width;
  final double height;

  static const double ballRadius = 30.0;
  static const double elasticity = 0.9;
  static const double physicsScale = 0.02;

  const BallSimulatorState({
    required this.world,
    this.ballBody,
    this.accelerometer,
    this.width = 0,
    this.height = 0,
  });

  // 新しい状態を作成するコピーメソッド
  BallSimulatorState copyWith({
    World? world,
    Body? ballBody,
    Vector2? accelerometer,
    double? width,
    double? height,
  }) {
    return BallSimulatorState(
      world: world ?? this.world,
      ballBody: ballBody ?? this.ballBody,
      accelerometer: accelerometer ?? this.accelerometer,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
