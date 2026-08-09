import 'package:flutter/material.dart';
import 'package:aurum/core/constants/app_colors.dart';
import 'package:aurum/core/constants/app_radius.dart';
import 'package:aurum/data/models/chart_range.dart';

class ChartRangeSelector extends StatelessWidget {
  final ChartRange selectedRange;
  final ValueChanged<ChartRange> onRangeSelected;

  const ChartRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutralLight,
        borderRadius: AppRadius.roundedSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartRange.values.map((range) {
          final isSelected = range == selectedRange;
          final is1Y = range == ChartRange.year1y;
          
          return GestureDetector(
            onTap: () {
              if (is1Y) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('1Y history requires a Pro tier. Showing max 30 days.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // We could prevent selection, but we'll allow it and it will just show 30 days of data.
                onRangeSelected(range);
              } else {
                onRangeSelected(range);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: AppRadius.roundedSmall,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                range.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: is1Y 
                      ? AppColors.secondaryText.withValues(alpha: 0.5) 
                      : (isSelected ? AppColors.primaryText : AppColors.secondaryText),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
