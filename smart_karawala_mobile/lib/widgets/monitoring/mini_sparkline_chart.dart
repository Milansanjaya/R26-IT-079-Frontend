import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniSparklineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color? fillColor;
  final double height;

  const MiniSparklineChart({
    super.key,
    required this.values,
    required this.lineColor,
    this.fillColor,
    this.height = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Container(
            height: 1.5,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: lineColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      );
    }

    List<FlSpot> dataPoints = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    // LineChart requires at least 2 points to draw a visible stroke
    if (dataPoints.length == 1) {
      dataPoints = [
        FlSpot(0.0, values.first),
        FlSpot(1.0, values.first),
      ];
    }

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final diff = maxY - minY;
    final padding = diff == 0 ? (minY == 0 ? 1.0 : minY.abs() * 0.1) : diff * 0.15;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              curveSmoothness: 0.35,
              color: lineColor,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (fillColor ?? lineColor).withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
