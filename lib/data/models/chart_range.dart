enum ChartRange {
  day24h('24H', Duration(hours: 24)),
  week7d('7D', Duration(days: 7)),
  month30d('30D', Duration(days: 30)),
  year1y('1Y', Duration(days: 365));

  final String label;
  final Duration duration;

  const ChartRange(this.label, this.duration);
}
