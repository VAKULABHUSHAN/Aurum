class PriceMovement {
  final double amountChange;
  final double percentageChange;

  const PriceMovement({
    required this.amountChange,
    required this.percentageChange,
  });

  bool get isPositive => amountChange > 0.0001;
  bool get isNegative => amountChange < -0.0001;
  bool get isNeutral => !isPositive && !isNegative;
}
