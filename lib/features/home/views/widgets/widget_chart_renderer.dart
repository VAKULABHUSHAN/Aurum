import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/core/constants/app_colors.dart';

class WidgetChartRenderer extends StatelessWidget {
  final List<IndianGoldRateModel> history;

  const WidgetChartRenderer({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return Container(
        color: Colors.transparent,
      );
    }

    final sortedHistory = List<IndianGoldRateModel>.from(history);
    sortedHistory.sort((a, b) {
      final dtA = DateTime.tryParse(a.timestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.timestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedHistory[i].price24kPerGram));
    }

    double high = sortedHistory.first.price24kPerGram;
    double low = sortedHistory.first.price24kPerGram;
    for (final r in sortedHistory) {
      final p = r.price24kPerGram;
      if (p > high) high = p;
      if (p < low) low = p;
    }

    final yDiff = (high - low).abs();
    final yPadding = yDiff > 0 ? yDiff * 0.2 : 10.0;
    final minY = (low - yPadding).clamp(0.0, double.infinity);
    final maxY = high + yPadding;

    return MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 200,
          child: Container(
            color: Colors.transparent,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: AppColors.primary,
                    barWidth: 3.0,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
