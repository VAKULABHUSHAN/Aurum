import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aurum/data/models/gold_history_model.dart';
import 'package:aurum/core/constants/app_colors.dart';

class WidgetChartRenderer extends StatelessWidget {
  final List<GoldHistoryModel> history;

  const WidgetChartRenderer({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return Container(
        color: Colors.transparent,
      );
    }

    final sortedHistory = List<GoldHistoryModel>.from(history);
    sortedHistory.sort((a, b) {
      final dtA = DateTime.tryParse(a.fetchTimestamp) ?? DateTime.tryParse(a.goldPrice.timestamp) ?? DateTime(0);
      final dtB = DateTime.tryParse(b.fetchTimestamp) ?? DateTime.tryParse(b.goldPrice.timestamp) ?? DateTime(0);
      return dtA.compareTo(dtB);
    });

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedHistory[i].goldPrice.priceGram24k));
    }

    double high = sortedHistory.first.goldPrice.priceGram24k;
    double low = sortedHistory.first.goldPrice.priceGram24k;
    for (final r in sortedHistory) {
      final p = r.goldPrice.priceGram24k;
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
