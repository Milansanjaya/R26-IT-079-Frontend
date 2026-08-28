import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LiveChart extends StatelessWidget {
  final String title;
  final List<double> values;
  final String unit;
  final Color color;
  final IconData? icon;
  final int decimalPlaces;
  final int sampleIntervalSeconds;
  final bool isLive;
  final bool allowNegative;

  const LiveChart({
    super.key,
    required this.title,
    required this.values,
    required this.unit,
    required this.color,
    this.icon,
    this.decimalPlaces = 1,
    this.sampleIntervalSeconds = 5,
    this.isLive = true,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final readings = values.where((value) => value.isFinite).toList();
    final latest = readings.isEmpty ? null : readings.last;
    final minimum = readings.isEmpty ? null : readings.reduce(math.min);
    final maximum = readings.isEmpty ? null : readings.reduce(math.max);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.62)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 8),
            color: AppColors.primary.withOpacity(0.07),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(
            title: title,
            latest: latest,
            unit: unit,
            color: color,
            icon: icon,
            decimalPlaces: decimalPlaces,
            isLive: isLive,
          ),
          const SizedBox(height: 14),
          if (readings.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RangeChip(
                  label: 'LOW',
                  value: minimum!,
                  unit: unit,
                  decimalPlaces: decimalPlaces,
                  color: color,
                ),
                _RangeChip(
                  label: 'HIGH',
                  value: maximum!,
                  unit: unit,
                  decimalPlaces: decimalPlaces,
                  color: color,
                ),
                _SampleChip(count: readings.length),
              ],
            ),
          const SizedBox(height: 18),
          SizedBox(
            height: 270,
            child: readings.isEmpty
                ? _EmptyChart(color: color, icon: icon)
                : _InteractiveLineChart(
                    values: readings,
                    unit: unit,
                    color: color,
                    decimalPlaces: decimalPlaces,
                    sampleIntervalSeconds: sampleIntervalSeconds,
                    allowNegative: allowNegative,
                  ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 7,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isLive ? color : AppColors.hint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isLive
                        ? 'Live readings • every $sampleIntervalSeconds seconds'
                        : 'Monitoring paused • last valid readings',
                    style: const TextStyle(
                      color: AppColors.hint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (readings.isNotEmpty)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 17,
                      color: AppColors.hint,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Touch to inspect',
                      style: TextStyle(color: AppColors.hint, fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String title;
  final double? latest;
  final String unit;
  final Color color;
  final IconData? icon;
  final int decimalPlaces;
  final bool isLive;

  const _ChartHeader({
    required this.title,
    required this.latest,
    required this.unit,
    required this.color,
    required this.icon,
    required this.decimalPlaces,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon ?? Icons.show_chart_rounded, color: color, size: 24),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  _LiveDot(active: isLive),
                  const SizedBox(width: 6),
                  Text(
                    isLive ? 'LIVE TREND' : 'LAST KNOWN',
                    style: TextStyle(
                      color: isLive ? AppColors.success : AppColors.hint,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 135),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'CURRENT',
                style: TextStyle(
                  color: AppColors.hint,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  latest == null
                      ? '--'
                      : '${latest!.toStringAsFixed(decimalPlaces)} $unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveDot extends StatelessWidget {
  final bool active;

  const _LiveDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.success : AppColors.hint,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final int decimalPlaces;
  final Color color;

  const _RangeChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.decimalPlaces,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(
                color: AppColors.hint,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            TextSpan(
              text: '${value.toStringAsFixed(decimalPlaces)} $unit',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  final int count;

  const _SampleChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count of 30 readings',
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InteractiveLineChart extends StatelessWidget {
  final List<double> values;
  final String unit;
  final Color color;
  final int decimalPlaces;
  final int sampleIntervalSeconds;
  final bool allowNegative;

  const _InteractiveLineChart({
    required this.values,
    required this.unit,
    required this.color,
    required this.decimalPlaces,
    required this.sampleIntervalSeconds,
    required this.allowNegative,
  });

  @override
  Widget build(BuildContext context) {
    final rawMin = values.reduce(math.min);
    final rawMax = values.reduce(math.max);
    final spread = rawMax - rawMin;
    final minimumPadding = decimalPlaces >= 3
        ? 0.010
        : unit == '%'
        ? 5.0
        : 2.0;
    final padding = math.max(spread * 0.18, minimumPadding);
    final minY = allowNegative
        ? rawMin - padding
        : math.max(0.0, rawMin - padding);
    final maxY = rawMax + padding;
    final yInterval = math.max((maxY - minY) / 4, 0.001);
    final maxX = values.length > 1 ? (values.length - 1).toDouble() : 1.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withOpacity(0.45),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.7)),
            left: BorderSide(color: AppColors.border.withOpacity(0.7)),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: decimalPlaces >= 3 ? 52 : 43,
              interval: yInterval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                space: 7,
                child: Text(
                  value.toStringAsFixed(decimalPlaces >= 3 ? 3 : 0),
                  style: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 29,
              interval: maxX,
              getTitlesWidget: (value, meta) {
                if (value.round() == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      values.length == 1 ? 'Latest' : 'Oldest',
                      style: const TextStyle(
                        color: AppColors.hint,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                if (value.round() == values.length - 1) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: const Text(
                      'Now',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.text,
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${spot.y.toStringAsFixed(decimalPlaces)} $unit',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
                .toList(),
          ),
          getTouchedSpotIndicator: (barData, indexes) => indexes
              .map(
                (_) => TouchedSpotIndicatorData(
                  FlLine(color: color.withOpacity(0.45), strokeWidth: 1),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: color,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(index.toDouble(), values[index]),
            ),
            isCurved: values.length > 2,
            curveSmoothness: 0.28,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: values.length <= 2,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: color,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.23),
                  color.withOpacity(0.015),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final Color color;
  final IconData? icon;

  const _EmptyChart({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.55)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon ?? Icons.show_chart_rounded, color: color),
          ),
          const SizedBox(height: 13),
          const Text(
            'Waiting for the first reading',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'The graph updates automatically every 5 seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
