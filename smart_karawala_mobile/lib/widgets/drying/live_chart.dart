import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LiveChart extends StatelessWidget {
  final String title;
  final List<double> values;
  final String unit;
  final Color color;

  const LiveChart({
    super.key,
    required this.title,
    required this.values,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Live values ($unit)",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: values.isEmpty
                ? const Center(
                    child: Text(
                      "Waiting for sensor data...",
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: values.length > 1
                          ? (values.length - 1)
                              .toDouble()
                          : 1,

                      borderData:
                          FlBorderData(show: false),

                      gridData:
                          const FlGridData(show: true),

                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles:
                              SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles:
                              SideTitles(
                            showTitles: false,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles:
                              SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            values.length,
                            (index) {
                              return FlSpot(
                                index.toDouble(),
                                values[index],
                              );
                            },
                          ),
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData:
                              const FlDotData(
                            show: false,
                          ),
                          belowBarData:
                              BarAreaData(
                            show: true,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
