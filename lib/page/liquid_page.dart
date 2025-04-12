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
  DateTime? _tapStartTime;
  Offset? _tapPosition;
  double _currentSizeMultiplier = 1.0;
  Timer? _updateTimer;
  bool _showColorPicker = false; // 色選択UIの表示状態

  // 基本となるパーティクルの半径（表示用）
  final double _basePreviewRadius = LiquidSimulatorState.particleRadius;

  // 色選択用のプリセットカラー
  final List<Color> _presetColors = [
    const Color(0x884FC3F7), // 半透明の水色（デフォルト）
    const Color(0x88F44336), // 半透明の赤
    const Color(0x884CAF50), // 半透明の緑
    const Color(0x88FFC107), // 半透明の黄色
    const Color(0x889C27B0), // 半透明の紫
    const Color(0x88FF9800), // 半透明のオレンジ
    const Color(0x882196F3), // 半透明の青
    const Color(0x88E91E63), // 半透明のピンク
  ];

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

  // 色選択UIの表示を切り替えるメソッド
  void _toggleColorPicker() {
    setState(() {
      _showColorPicker = !_showColorPicker;
    });
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

          return Stack(
            children: [
              // GestureDetectorは変更なし
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  setState(() {
                    _tapStartTime = DateTime.now();
                    _tapPosition = details.localPosition;
                    _currentSizeMultiplier = 1.0;
                  });

                  _updateTimer =
                      Timer.periodic(Duration(milliseconds: 16), (timer) {
                    _updatePreviewSize();
                  });
                },
                onTapUp: (details) {
                  _updateTimer?.cancel();
                  _updateTimer = null;

                  if (_tapStartTime != null && _tapPosition != null) {
                    // 現在のサイズ倍率でパーティクルを追加
                    ref
                        .read(liquidSimulatorProvider.notifier)
                        .addParticleAtPosition(_tapPosition!.dx,
                            _tapPosition!.dy, _currentSizeMultiplier);

                    setState(() {
                      _tapStartTime = null;
                      _tapPosition = null;
                    });
                  }
                },
                onTapCancel: () {
                  _updateTimer?.cancel();
                  _updateTimer = null;

                  setState(() {
                    _tapStartTime = null;
                    _tapPosition = null;
                  });
                },
                child: Container(
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
                      defaultLiquidColor:
                          simulatorState.currentColor, // 現在の色を使用
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),

              // タッチプレビュー - プレビューの色を現在選択されている色に変更
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
                      color: simulatorState.currentColor, // 現在選択されている色
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),

              // 色選択ボタン - 画面右下に配置
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: _toggleColorPicker,
                  backgroundColor: simulatorState.currentColor,
                  child: Icon(
                    Icons.color_lens,
                    color: Colors.white,
                  ),
                ),
              ),

              // 色選択パネル - 表示/非表示を切り替え
              if (_showColorPicker)
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 8,
                          runSpacing: 8,
                          children: _presetColors.map((color) {
                            return GestureDetector(
                              onTap: () {
                                // 色を選択したら色選択プロバイダーを更新
                                ref
                                    .read(liquidSimulatorProvider.notifier)
                                    .updateColor(color);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: simulatorState.currentColor == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    if (simulatorState.currentColor == color)
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
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
