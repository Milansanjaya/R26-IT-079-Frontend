import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LiveChart extends StatelessWidget {
  final List<double> temperatures;
  final List<double> humidities;

  const LiveChart({
    super.key,
    required this.temperatures,
    required this.humidities,
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Live Data (Today)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: true),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true),
                  ),
                ),

                lineBarsData: [

                  LineChartBarData(
                    spots: List.generate(
                      temperatures.length,
                      (i) => FlSpot(
                        i.toDouble(),
                        temperatures[i],
                      ),
                    ),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),

                  LineChartBarData(
                    spots: List.generate(
                      humidities.length,
                      (i) => FlSpot(
                        i.toDouble(),
                        humidities[i],
                      ),
                    ),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
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