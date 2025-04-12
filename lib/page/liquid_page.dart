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
      appBar: AppBar(
        title: const Text('液体シミュレーション - 端末の傾きで水が動きます'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 画面サイズが変更されたときに通知
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(liquidSimulatorProvider.notifier)
                .updateScreenSize(constraints.maxWidth, constraints.maxHeight);
          });

          return Stack(
            children: [
              // 液体パーティクル
              Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CustomPaint(
                    painter: LiquidPainter(
                      particles: simulatorState.particles,
                      particleRadius: LiquidSimulatorState.particleRadius,
                      physicsScale: LiquidSimulatorState.physicsScale,
                      width: simulatorState.width,
                      height: simulatorState.height,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
