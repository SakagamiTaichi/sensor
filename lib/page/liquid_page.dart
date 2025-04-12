import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensor/component/liquid.dart';
import 'package:sensor/provider/liquid_simulator_provider.dart';
import 'package:sensor/state/liquid_simulator_state.dart';

class LiquidPage extends StatelessWidget {
  const LiquidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '液体シミュレーション (Forge2D with Riverpod)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LiquidSimulationPage(),
    );
  }
}

class LiquidSimulationPage extends ConsumerStatefulWidget {
  const LiquidSimulationPage({super.key});

  @override
  ConsumerState<LiquidSimulationPage> createState() =>
      _LiquidSimulationPageState();
}

class _LiquidSimulationPageState extends ConsumerState<LiquidSimulationPage> {
  @override
  Widget build(BuildContext context) {
    final simulatorState = ref.watch(liquidSimulatorProvider);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 画面サイズが変更されたときに通知
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(liquidSimulatorProvider.notifier)
                .updateScreenSize(constraints.maxWidth, constraints.maxHeight);
          });

          // GestureDetectorを直接CustomPaintに適用
          return GestureDetector(
            // この設定が重要：透明な領域でもタップを検知するようにする
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              // タップ位置を物理座標に変換してパーティクルを追加
              final position = details.localPosition;
              ref
                  .read(liquidSimulatorProvider.notifier)
                  .addParticleAtPosition(position.dx, position.dy);
            },
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.grey[200], // 背景色を追加
              child: CustomPaint(
                painter: LiquidPainter(
                  particles: simulatorState.particles,
                  particleRadius: LiquidSimulatorState.particleRadius,
                  physicsScale: LiquidSimulatorState.physicsScale,
                  width: simulatorState.width,
                  height: simulatorState.height,
                ),
                // サイズをいっぱいに
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            ),
          );
        },
      ),
    );
  }
}
