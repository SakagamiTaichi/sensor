import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

class Ball extends StatefulWidget {
  final World world;
  final double ballRadius;
  final double physicsScale;
  final double width;
  final double height;
  final double elasticity;

  const Ball({
    super.key,
    required this.world,
    required this.ballRadius,
    required this.physicsScale,
    required this.width,
    required this.height,
    this.elasticity = 0.9,
  });

  @override
  State<Ball> createState() => _PhysicalBallState();
}

class _PhysicalBallState extends State<Ball> {
  Body? _ballBody;

  @override
  void initState() {
    super.initState();
    _createBallBody();
  }

  @override
  void didUpdateWidget(Ball oldWidget) {
    super.didUpdateWidget(oldWidget);

    // サイズが変わった場合などに再作成
    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.ballRadius != widget.ballRadius) {
      _destroyBallBody();
      _createBallBody();
    }
  }

  void _createBallBody() {
    final double scaledBallRadius = widget.ballRadius * widget.physicsScale;

    // ボールを作成
    final ballBodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position.setZero();

    _ballBody = widget.world.createBody(ballBodyDef);

    final ballShape = CircleShape()..radius = scaledBallRadius;

    final ballFixtureDef = FixtureDef(ballShape)
      ..density = 1.0
      ..friction = 0.2
      ..restitution = widget.elasticity;

    _ballBody!.createFixture(ballFixtureDef);
  }

  void _destroyBallBody() {
    if (_ballBody != null) {
      widget.world.destroyBody(_ballBody!);
      _ballBody = null;
    }
  }

  @override
  void dispose() {
    _destroyBallBody();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BallPainter(
        ballBody: _ballBody,
        ballRadius: widget.ballRadius,
        physicsScale: widget.physicsScale,
        width: widget.width,
        height: widget.height,
      ),
      size: Size(widget.width, widget.height),
    );
  }
}

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
    return ballBody != oldDelegate.ballBody;
  }
}
