class GoldBarModel {
  final DateTime barStart;
  final double open;
  final double high;
  final double low;
  final double close;

  GoldBarModel({
    required this.barStart,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory GoldBarModel.fromJson(Map<String, dynamic> json) {
    return GoldBarModel(
      barStart: DateTime.parse(json['bar_start']),
      open: double.tryParse(json['open'].toString()) ?? 0.0,
      high: double.tryParse(json['high'].toString()) ?? 0.0,
      low: double.tryParse(json['low'].toString()) ?? 0.0,
      close: double.tryParse(json['close'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bar_start': barStart.toIso8601String(),
      'open': open.toString(),
      'high': high.toString(),
      'low': low.toString(),
      'close': close.toString(),
    };
  }
}
