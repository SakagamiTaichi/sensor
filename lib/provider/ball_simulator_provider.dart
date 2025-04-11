// ball_simulator_provider.dart
import 'package:forge2d/forge2d.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sensor/state/ball_simulator_state.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'ball_simulator_provider.g.dart';

// Riverpodを使った状態管理
@riverpod
class BallSimulator extends _$BallSimulator {
  @override
  BallSimulatorState build() {
    // 初期状態を作成 - 重力なしの物理ワールド
    final world = World(Vector2(0, 0));
    final state = BallSimulatorState(world: world);

    // 加速度センサーのリスナーをセットアップ
    _setupAccelerometerListener();

    // タイマーをセットアップして物理シミュレーションを更新
    _setupSimulationTimer();

    return state;
  }

  void _setupAccelerometerListener() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      // 加速度データを更新
      state = state.copyWith(accelerometer: Vector2(-event.x, event.y));

      if (state.accelerometer == null) return;

      // 物理世界の重力を更新
      state.world.gravity.setFrom(state.accelerometer!);
    });
  }

  void _setupSimulationTimer() {
    // 60FPSでシミュレーションを更新
    Future.delayed(const Duration(milliseconds: 16), _updateSimulation);
  }

  void _updateSimulation() {
    if (state.ballBody != null) {
      // 物理世界を1ステップ進める
      state.world.stepDt(1 / 60);

      // 状態を更新して再描画をトリガー
      state = state.copyWith(world: state.world);
    }

    // 次のフレームの更新をスケジュール
    _setupSimulationTimer();
  }

  // 画面サイズが変わったときに呼び出されるメソッド
  void updateScreenSize(double width, double height) {
    if (width == state.width && height == state.height) return;

    state = state.copyWith(width: width, height: height);
    _createPhysicsObjects();
  }

  // 物理オブジェクトを作成するメソッド
  void _createPhysicsObjects() {
    final width = state.width;
    final height = state.height;

    // 画面がまだ測定されていない場合は早期リターン
    if (width == 0 || height == 0) return;

    // 既存のオブジェクトをクリア
    state.world.bodies.toList().forEach((body) {
      state.world.destroyBody(body);
    });

    // 物理スケールの係数
    final double scale = BallSimulatorState.physicsScale;
    final double scaledWidth = width * scale;
    final double scaledHeight = height * scale;
    final double scaledBallRadius = BallSimulatorState.ballRadius * scale;

    // 壁を作成
    _createWall(Vector2(-scaledWidth / 2, 0), Vector2(0.1, scaledHeight)); // 左壁
    _createWall(Vector2(scaledWidth / 2, 0), Vector2(0.1, scaledHeight)); // 右壁
    _createWall(Vector2(0, -scaledHeight / 2), Vector2(scaledWidth, 0.1)); // 上壁
    _createWall(Vector2(0, scaledHeight / 2), Vector2(scaledWidth, 0.1)); // 下壁

    // ボールを作成
    final ballBodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position.setZero();

    final ballBody = state.world.createBody(ballBodyDef);

    final ballShape = CircleShape()..radius = scaledBallRadius;

    final ballFixtureDef = FixtureDef(ballShape)
      ..density = 1.0
      ..friction = 0.2
      ..restitution = BallSimulatorState.elasticity;

    ballBody.createFixture(ballFixtureDef);

    // 状態を更新
    state = state.copyWith(ballBody: ballBody);
  }

  Body _createWall(Vector2 position, Vector2 size) {
    final wallBodyDef = BodyDef()
      ..type = BodyType.static
      ..position.setFrom(position);

    final wallBody = state.world.createBody(wallBodyDef);

    final wallShape = PolygonShape()
      ..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0);

    final wallFixtureDef = FixtureDef(wallShape)
      ..friction = 0.3
      ..restitution = BallSimulatorState.elasticity;

    wallBody.createFixture(wallFixtureDef);

    return wallBody;
  }
}
