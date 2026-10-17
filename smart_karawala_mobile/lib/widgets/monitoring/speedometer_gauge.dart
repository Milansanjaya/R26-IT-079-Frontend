import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpeedometerGauge extends StatefulWidget {
  final double value; // 0.0 to 100.0 (Dryness percentage)
  final String label;
  final double size;

  const SpeedometerGauge({
    super.key,
    required this.value,
    this.label = "DRYNESS INDEX",
    this.size = 200,
  });

  @override
  State<SpeedometerGauge> createState() => _SpeedometerGaugeState();
}

class _SpeedometerGaugeState extends State<SpeedometerGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SpeedometerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value;
        return SizedBox(
          width: widget.size,
          height: widget.size * 0.75,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size * 0.75),
                painter: _SpeedometerPainter(value: currentValue),
              ),
              Positioned(
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${currentValue.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: widget.size * 0.16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xff103F73),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: widget.size * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double value; // 0 to 100

  _SpeedometerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final radius = size.width * 0.38;
    const strokeWidth = 16.0;

    const startAngle = math.pi * 0.82; // ~147 degrees
    const totalSweepAngle = math.pi * 1.36; // ~245 degrees arc

    // Draw Background Track
    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle,
      false,
      trackPaint,
    );

    // Colored Arc Segments (Red -> Yellow -> Green -> Blue)
    final List<Color> colors = [
      Colors.red.shade400,
      Colors.amber.shade600,
      Colors.green.shade600,
      Colors.blue.shade600,
    ];

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + totalSweepAngle,
      colors: colors,
    );

    final progressSweepAngle = (value.clamp(0.0, 100.0) / 100.0) * totalSweepAngle;

    final activePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweepAngle,
      false,
      activePaint,
    );

    // Needle Angle
    final needleAngle = startAngle + progressSweepAngle;
    final needleLength = radius * 0.72;

    // Draw Needle Base Hub
    final hubPaint = Paint()
      ..color = const Color(0xff103F73)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, hubPaint);

    final hubInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, hubInnerPaint);

    // Draw Needle Line
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = const Color(0xff103F73)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
