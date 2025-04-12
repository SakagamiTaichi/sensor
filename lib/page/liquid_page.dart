import 'dart:async';
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
  // タップの開始時間と位置を追跡するための変数
  DateTime? _tapStartTime;
  Offset? _tapPosition;
  double _currentSizeMultiplier = 1.0;
  Timer? _updateTimer;

  // 基本となるパーティクルの半径（表示用）
  final double _basePreviewRadius = LiquidSimulatorState.particleRadius;

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // タップ長さに基づくサイズ計算
  void _updatePreviewSize() {
    if (_tapStartTime != null) {
      final duration = DateTime.now().difference(_tapStartTime!);
      final durationInSeconds = duration.inMilliseconds / 1000.0;

      setState(() {
        // サイズ倍率を1.0〜5.0の間に制限
        _currentSizeMultiplier = 1.0 + durationInSeconds.clamp(0.0, 4.0);
      });
    }
  }

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

          // GestureDetectorを更新
          return GestureDetector(
            // この設定が重要：透明な領域でもタップを検知するようにする
            behavior: HitTestBehavior.opaque,

            // タップダウン - タップの開始時間と位置を記録
            onTapDown: (details) {
              setState(() {
                _tapStartTime = DateTime.now();
                _tapPosition = details.localPosition;
                _currentSizeMultiplier = 1.0;
              });

              // タイマーを開始して、プレビューサイズを定期的に更新
              _updateTimer =
                  Timer.periodic(Duration(milliseconds: 16), (timer) {
                _updatePreviewSize();
              });
            },

            // タップアップ - タップの長さに基づいてボールを追加
            onTapUp: (details) {
              _updateTimer?.cancel();
              _updateTimer = null;

              if (_tapStartTime != null && _tapPosition != null) {
                // 現在のサイズ倍率でパーティクルを追加
                ref
                    .read(liquidSimulatorProvider.notifier)
                    .addParticleAtPosition(_tapPosition!.dx, _tapPosition!.dy,
                        _currentSizeMultiplier);

                // タップ追跡をリセット
                setState(() {
                  _tapStartTime = null;
                  _tapPosition = null;
                });
              }
            },

            // タップキャンセル - タップ追跡をリセット
            onTapCancel: () {
              _updateTimer?.cancel();
              _updateTimer = null;

              setState(() {
                _tapStartTime = null;
                _tapPosition = null;
              });
            },

            child: Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.grey[200], // 背景色
                  child: CustomPaint(
                    painter: LiquidPainter(
                      particles: simulatorState.particles,
                      particleRadius: LiquidSimulatorState.particleRadius,
                      physicsScale: LiquidSimulatorState.physicsScale,
                      width: simulatorState.width,
                      height: simulatorState.height,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),

                // タップ中の場合、リアルタイムでサイズが変わるボールのプレビューを表示
                if (_tapStartTime != null && _tapPosition != null)
                  Positioned(
                    left: _tapPosition!.dx -
                        (_basePreviewRadius * _currentSizeMultiplier),
                    top: _tapPosition!.dy -
                        (_basePreviewRadius * _currentSizeMultiplier),
                    child: Container(
                      width: _basePreviewRadius * 2 * _currentSizeMultiplier,
                      height: _basePreviewRadius * 2 * _currentSizeMultiplier,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
