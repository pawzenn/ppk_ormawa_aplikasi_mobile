// lib/shared/widgets/bar_chart_simple.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSimple extends StatelessWidget {
  final List<double> values;
  final List<String> bottomLabels;
  final Color color;

  const BarChartSimple({
    super.key,
    required this.values,
    required this.bottomLabels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[
      for (var i = 0; i < values.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i],
              width: 18,
              borderRadius: BorderRadius.circular(6),
              color: color,
            ),
          ],
        ),
    ];

    return BarChart(
      BarChartData(
        minY: 0,

        // === SENTUHAN & TOOLTIP ===
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // Versi baru: pakai getTooltipColor, bukan tooltipBgColor
            getTooltipColor: (group) => const Color(0xFF1E7A3F),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              return BarTooltipItem(
                value.toStringAsFixed(0), // mis. 20
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),

        barGroups: groups,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= bottomLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    bottomLabels[i],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
