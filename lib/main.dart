// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge2d/forge2d.dart';
import 'package:sensor/provider/ball_simulator_provider.dart';
import 'package:sensor/state/ball_simulator_state.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const BallSimulationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BallSimulationPage> createState() => _BallSimulationPageState();
}

class _BallSimulationPageState extends ConsumerState<BallSimulationPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // フレーム描画後に実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      ref
          .read(ballSimulatorProvider.notifier)
          .updateScreenSize(size.width, size.height);
    });
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

// class BallSimulationPage extends ConsumerWidget {
//   const BallSimulationPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Riverpodを使って状態を監視
//     final simulatorState = ref.watch(ballSimulatorProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('重力ボールシミュレーション (Forge2D with Riverpod & Freezed)'),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           // 画面サイズを更新
//           // ref
//           //     .read(ballSimulatorProvider.notifier)
//           //     .updateScreenSize(constraints.maxWidth, constraints.maxHeight);

//           return Center(
//             child: Container(
//               width: constraints.maxWidth,
//               height: constraints.maxHeight,
//               color: Colors.grey[200],
//               child: CustomPaint(
//                 painter: BallPainter(
//                   ballBody: simulatorState.ballBody,
//                   ballRadius: BallSimulatorState.ballRadius,
//                   physicsScale: BallSimulatorState.physicsScale,
//                   width: simulatorState.width,
//                   height: simulatorState.height,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ボールを描画するためのカスタムペインター
class BallPainter extends CustomPainter {
  final Body? ballBody;
  final double ballRadius;
  final double physicsScale;
  final double width;
  final double height;

  BallPainter({
    required this.ballBody,
    required this.ballRadius,
    required this.physicsScale,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ballBody == null) return;

    final position = ballBody!.position;

    // 物理座標から画面座標に変換
    final x = width / 2 + position.x / physicsScale;
    final y = height / 2 + position.y / physicsScale;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [Colors.lightBlue, Colors.blue[800]!],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y),
        radius: ballRadius,
      ));

    // ボールの描画
    canvas.drawCircle(
      Offset(x, y),
      ballRadius,
      paint,
    );

    // 光沢効果の追加
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(x - ballRadius * 0.3, y - ballRadius * 0.3),
      ballRadius * 0.2,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(BallPainter oldDelegate) {
    return true; // 毎フレーム再描画
  }
}
