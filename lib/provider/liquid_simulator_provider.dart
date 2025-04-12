// liquid_simulator_provider.dart
import 'dart:math';
import 'package:forge2d/forge2d.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sensor/state/liquid_simulator_state.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'liquid_simulator_provider.g.dart';

// Riverpodを使った液体シミュレーション状態管理
@riverpod
class LiquidSimulator extends _$LiquidSimulator {
  @override
  LiquidSimulatorState build() {
    // 初期状態を作成 - 重力なしの物理ワールド
    final world = World(Vector2(0, 0));
    final state = LiquidSimulatorState(world: world);

    // 加速度センサーのリスナーをセットアップ
    _setupAccelerometerListener();

    // タイマーをセットアップして物理シミュレーションを更新
    _setupSimulationTimer();

    return state;
  }

  void _setupAccelerometerListener() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      // 加速度データを更新 - スケールファクタを追加して効果を強調
      state =
          state.copyWith(accelerometer: Vector2(-event.x * 3.0, event.y * 3.0));

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
    if (state.particles.isNotEmpty) {
      // 物理世界を1ステップ進める
      state.world.stepDt(1 / 60);

      // パーティクル間の相互作用を計算
      _calculateParticleInteractions();

      // 状態を更新して再描画をトリガー
      state = state.copyWith(world: state.world);
    }

    // 次のフレームの更新をスケジュール
    _setupSimulationTimer();
  }

  // パーティクル間の相互作用を計算（凝集効果を模倣）
  void _calculateParticleInteractions() {
    final particles = state.particles;

    // 単純な最近傍探索による凝集力の計算
    final interactionRadius = 1.5 *
        LiquidSimulatorState.particleRadius *
        LiquidSimulatorState.physicsScale;

    for (int i = 0; i < particles.length; i++) {
      final bodyA = particles[i];
      final posA = bodyA.position;

      for (int j = i + 1; j < particles.length; j++) {
        final bodyB = particles[j];
        final posB = bodyB.position;

        final dist = (posB - posA).length;

        // 近すぎるパーティクルに弱い凝集力を加える
        if (dist < interactionRadius && dist > 0.01) {
          final direction = (posB - posA).normalized();
          final force = direction.scaled(0.05 / (dist * dist));

          // 力を適用
          bodyA.applyForce(force.scaled(bodyA.mass));
          bodyB.applyForce(force.scaled(-bodyB.mass));
        }
      }
    }
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
    final double scale = LiquidSimulatorState.physicsScale;
    final double scaledWidth = width * scale;
    final double scaledHeight = height * scale;
    final double scaledParticleRadius =
        LiquidSimulatorState.particleRadius * scale;

    // 壁を作成
    _createWall(Vector2(-scaledWidth / 2, 0), Vector2(0.1, scaledHeight)); // 左壁
    _createWall(Vector2(scaledWidth / 2, 0), Vector2(0.1, scaledHeight)); // 右壁
    _createWall(Vector2(0, -scaledHeight / 2), Vector2(scaledWidth, 0.1)); // 上壁
    _createWall(Vector2(0, scaledHeight / 2), Vector2(scaledWidth, 0.1)); // 下壁

    // パーティクルを作成
    final rand = Random();
    final List<Body> particles = [];

    for (int i = 0; i < LiquidSimulatorState.particleCount; i++) {
      // ランダムな開始位置 - 画面中心付近に集中
      final startX = (rand.nextDouble() - 0.5) * scaledWidth * 0.5;
      final startY = (rand.nextDouble() - 0.5) * scaledHeight * 0.5;

      final particleBodyDef = BodyDef()
        ..type = BodyType.dynamic
        ..position = Vector2(startX, startY)
        ..bullet = false // パフォーマンスのため、bulletは無効に
        ..allowSleep = true // スリープを許可して最適化
        ..linearDamping = 0.4; // 水の粘性を模倣

      final particleBody = state.world.createBody(particleBodyDef);

      final shape = CircleShape()..radius = scaledParticleRadius;

      final fixtureDef = FixtureDef(shape)
        ..density = LiquidSimulatorState.particleDensity
        ..friction = LiquidSimulatorState.particleFriction
        ..restitution = LiquidSimulatorState.elasticity
        ..filter.groupIndex = -1; // 同じグループなので衝突応答を軽減

      particleBody.createFixture(fixtureDef);
      particles.add(particleBody);
    }

    // 状態を更新
    state = state.copyWith(particles: particles);
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
      ..restitution = 0.4;

    wallBody.createFixture(wallFixtureDef);

    return wallBody;
  }
}
