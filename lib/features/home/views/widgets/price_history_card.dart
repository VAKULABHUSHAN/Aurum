import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/core/constants/app_spacing.dart';
import 'package:aurum/core/theme/app_text_styles.dart';
import 'package:aurum/core/utils/currency_formatter.dart';
import 'package:aurum/core/utils/date_formatter.dart';
import 'package:aurum/data/models/indian_gold_rate_model.dart';
import 'package:aurum/data/models/chart_range.dart';
import 'package:aurum/features/home/views/widgets/chart_range_selector.dart';

class PriceHistoryCard extends StatelessWidget {
  final List<IndianGoldRateModel> history;
  final ChartRange selectedRange;
  final ValueChanged<ChartRange> onRangeSelected;
  final double? highPrice;
  final double? lowPrice;

  const PriceHistoryCard({
    super.key,
    required this.history,
    required this.selectedRange,
    required this.onRangeSelected,
    required this.highPrice,
    required this.lowPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnoughData = history.length >= 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Range Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Price History',
                style: AppTextStyles.cardTitle,
              ),
              ChartRangeSelector(
                selectedRange: selectedRange,
                onRangeSelected: onRangeSelected,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // High / Low Row (Only shown if sufficient data exists)
          if (hasEnoughData && highPrice != null && lowPrice != null) ...[
            Row(
              children: [
                Row(
                  children: [
                    const Text('High  ', style: AppTextStyles.label),
                    Text(
                      CurrencyFormatter.formatPrice(highPrice!),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
                Row(
                  children: [
                    const Text('Low  ', style: AppTextStyles.label),
                    Text(
                      CurrencyFormatter.formatPrice(lowPrice!),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Chart or Empty State
          if (!hasEnoughData)
            _buildEmptyState()
          else
            _buildChart(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Building price history...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Chart will appear when more data points are collected locally.',
              style: AppTextStyles.label,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].price24kPerGram));
    }

    final high = highPrice ?? history.first.price24kPerGram;
    final low = lowPrice ?? history.first.price24kPerGram;
    final yDiff = (high - low).abs();
    final yPadding = yDiff > 0 ? yDiff * 0.2 : 10.0;
    final minY = (low - yPadding).clamp(0.0, double.infinity);
    final maxY = high + yPadding;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yDiff > 0 ? (yDiff / 2) : 5,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: _calculateBottomInterval(history.length),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= history.length) {
                    return const SizedBox.shrink();
                  }

                  final timestamp = history[index].timestamp;

                  final label = DateFormatter.formatShortDate(timestamp);

                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.primaryText,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final timestamp = (index >= 0 && index < history.length)
                      ? history[index].timestamp
                      : '';

                  final formattedTime = DateFormatter.formatFullDateTime(timestamp);

                  final formattedPrice = CurrencyFormatter.formatPrice(spot.y);

                  return LineTooltipItem(
                    '$formattedPrice\n$formattedTime',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.15,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateBottomInterval(int count) {
    if (count <= 4) return 1;
    if (count <= 8) return 2;
    if (count <= 15) return 3;
    return (count / 4).floorToDouble();
  }
}
