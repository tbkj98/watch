import 'dart:math';

import 'package:flutter/material.dart';

class ClockPage extends StatelessWidget {
  const ClockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.width,
        child: CustomPaint(
          painter: ClockPainter(clockRadius: 150.0),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double clockRadius;

  ClockPainter({required this.clockRadius});

  Offset _drawCircle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    paint.shader = const RadialGradient(
      stops: [0.5, 0.9],
      colors: [Colors.black87, Colors.blue],
    ).createShader(Rect.fromCircle(center: center, radius: clockRadius));

    canvas.drawCircle(center, clockRadius, paint);
    return center;
  }

  void _drawNumber(Canvas canvas, Offset offset, String data) {
    final span = TextSpan(
      text: data,
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
      ),
    );

    final TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final paintOffset = Offset(
      offset.dx - painter.width / 2,
      offset.dy - painter.height / 2,
    );
    painter.paint(canvas, paintOffset);
  }

  Offset _getNumberOffset(int number, int max, Offset center, double border) {
    final angle = (3 / 2 * pi) + (pi / 6 * number);
    double x = center.dx + (clockRadius - border) * cos(angle);
    double y = center.dy + (clockRadius - border) * sin(angle);
    return Offset(x, y);
  }

  void _drawNumbers(
      Canvas canvas, Size size, Offset center, double border, int max) {
    final list = List.generate(max, (index) => index + 1);
    for (var item in list) {
      _drawNumber(canvas, _getNumberOffset(item, max, center, border), '$item');
    }
  }

  void _drawHand(
      Canvas canvas, Size size, Offset center, double border, int max) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    final offset = _getNumberOffset(1, max, center, border);
    canvas.drawLine(center, Offset(offset.dx - 0, offset.dy - 0), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const border = 30.0;
    const max = 12;
    final center = _drawCircle(canvas, size);
    _drawNumbers(canvas, size, center, border, max);
    _drawHand(canvas, size, center, border, max);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ClockPainter oldDelegate) => false;
}
