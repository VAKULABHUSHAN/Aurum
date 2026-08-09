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
          return GestureDetector(
            onTap: () => onRangeSelected(range),
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
                  color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
