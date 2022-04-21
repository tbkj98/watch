import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ClockPage extends StatelessWidget {
  final double clockRadius;
  const ClockPage({this.clockRadius = 150.0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Clock(clockRadius: clockRadius),
            ClockHand(clockRadius: clockRadius),
          ],
        ),
      ),
    );
  }
}

class Clock extends StatelessWidget {
  const Clock({
    Key? key,
    required this.clockRadius,
  }) : super(key: key);

  final double clockRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(
        clockRadius: clockRadius,
      ),
    );
  }
}

class ClockHand extends StatefulWidget {
  final double clockRadius;

  const ClockHand({
    Key? key,
    required this.clockRadius,
  }) : super(key: key);

  @override
  State<ClockHand> createState() => _ClockHandState();
}

class _ClockHandState extends State<ClockHand> {
  late final Timer timer;
  final timeNotifier = ValueNotifier<DateTime>(DateTime.now());

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeNotifier.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: timeNotifier,
      builder: (context, value, child) {
        return CustomPaint(
          painter: ClockHandPainter(
            clockRadius: widget.clockRadius,
            dateTime: value,
          ),
        );
      },
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

  void _drawNumbers(
      Canvas canvas, Size size, Offset center, double border, int max) {
    final list = List.generate(max, (index) => index + 1);
    for (var item in list) {
      _drawNumber(
        canvas,
        _getNumberOffset(item, max, center, border, clockRadius),
        '$item',
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const border = 30.0;
    const max = 12;
    final center = _drawCircle(canvas, size);
    _drawNumbers(canvas, size, center, border, max);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ClockPainter oldDelegate) => false;
}

Offset _getNumberOffset(
    int number, int max, Offset center, double border, double radius) {
  final angle = (3 / 2 * math.pi) + (2 * math.pi / max * number);
  double x = center.dx + (radius - border) * math.cos(angle);
  double y = center.dy + (radius - border) * math.sin(angle);
  return Offset(x, y);
}

class ClockHandPainter extends CustomPainter {
  final double clockRadius;
  final DateTime dateTime;

  final hourHandPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.white
    ..strokeWidth = 7.0
    ..strokeCap = StrokeCap.round;

  final minuteHandPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.blue
    ..strokeWidth = 5.0
    ..strokeCap = StrokeCap.round;

  final secondHandPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.deepOrange
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  ClockHandPainter({required this.dateTime, required this.clockRadius});

  void _drawHand(Canvas canvas, Size size, Offset center, double border,
      int max, int val, Paint paint) {
    final offset = _getNumberOffset(val, max, center, border, clockRadius);
    canvas.drawLine(center, Offset(offset.dx, offset.dy), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const border = 30.0;
    final center = Offset(size.width / 2, size.height / 2);
    _drawHand(canvas, size, center, border, 12, dateTime.hour, hourHandPaint);
    _drawHand(
        canvas, size, center, border, 60, dateTime.minute, minuteHandPaint);
    _drawHand(
        canvas, size, center, border, 60, dateTime.second, secondHandPaint);
  }

  @override
  bool shouldRepaint(ClockHandPainter oldDelegate) =>
      dateTime != oldDelegate.dateTime;

  @override
  bool shouldRebuildSemantics(ClockHandPainter oldDelegate) => false;
}
