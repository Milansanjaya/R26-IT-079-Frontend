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
      return SizedBox(height: height);
    }

    final dataPoints = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.15;

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
              barWidth: 2.0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (fillColor ?? lineColor).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
