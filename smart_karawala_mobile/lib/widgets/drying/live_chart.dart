import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LiveChart extends StatelessWidget {
  final List<double> temperatures;
  final List<double> humidities;
  final List<double> weights;
  final String title;

  const LiveChart({
    super.key,
    this.temperatures = const [],
    this.humidities = const [],
    this.weights = const [],
    this.title = "Live Sensor Data",
  });

  @override
  Widget build(BuildContext context) {
    final maxLength = [
      temperatures.length,
      humidities.length,
      weights.length,
    ].fold<int>(0, (value, element) => value > element ? value : element);
    final hasData = maxLength > 0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 18,
            children: [

              if (temperatures.isNotEmpty)
                _legend(Colors.red, "Temperature"),

              if (humidities.isNotEmpty)
                _legend(Colors.blue, "Humidity"),

              if (weights.isNotEmpty)
                _legend(Colors.green, "Weight"),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: hasData
                ? LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxLength.toDouble() - 1,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                          ),
                        ),
                      ),
                      lineBarsData: [
                        if (temperatures.isNotEmpty)
                          _line(temperatures, Colors.red),
                        if (humidities.isNotEmpty)
                          _line(humidities, Colors.blue),
                        if (weights.isNotEmpty)
                          _line(weights, Colors.green),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FBFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xffD8E6F5),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: Color(0xff93A7BE),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No live readings yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff4B5563),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "The chart layout stays visible until the device sends data.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff6B7280),
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

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(width: 5),

        Text(text),
      ],
    );
  }

  LineChartBarData _line(
      List<double> values,
      Color color,
      ) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(
          i.toDouble(),
          values[i],
        ),
      ),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
  }
}