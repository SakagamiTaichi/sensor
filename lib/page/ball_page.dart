import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensor/component/ball.dart';
import 'package:sensor/provider/ball_simulator_provider.dart';
import 'package:sensor/state/ball_simulator_state.dart';

class BallPage extends StatelessWidget {
  const BallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '重力ボールシミュレーション (Forge2D with Riverpod & Freezed)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BallSimulationPage(),
    );
  }
}

class BallSimulationPage extends ConsumerStatefulWidget {
  const BallSimulationPage({super.key});

  @override
  ConsumerState<BallSimulationPage> createState() => _BallSimulationPageState();
}

class _BallSimulationPageState extends ConsumerState<BallSimulationPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final simulatorState = ref.watch(ballSimulatorProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('重力ボールシミュレーション (Forge2D with Riverpod & Freezed)'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(ballSimulatorProvider.notifier)
                .updateScreenSize(constraints.maxWidth, constraints.maxHeight);
          });
          return Center(
              child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.grey[200],
            child: CustomPaint(
              painter: BallPainter(
                ballBody: simulatorState.ballBody,
                ballRadius: BallSimulatorState.ballRadius,
                physicsScale: BallSimulatorState.physicsScale,
                width: simulatorState.width,
                height: simulatorState.height,
              ),
            ),
          ));
        },
      ),
    );
  }
}
