import 'package:hive/hive.dart';

part 'indian_gold_rate_model.g.dart';

@HiveType(typeId: 2)
class IndianGoldRateModel {
  @HiveField(0)
  final double price24kPerGram;

  @HiveField(1)
  final double price22kPerGram;

  @HiveField(2)
  final double price18kPerGram;

  @HiveField(3)
  final String timestamp;

  @HiveField(4)
  final String source;

  @HiveField(5)
  final String unit;

  @HiveField(6)
  final double? purity999;

  @HiveField(7)
  final double? purity916;

  @HiveField(8)
  final double? purity750;

  @HiveField(9)
  final String session;

  @HiveField(10)
  final String rateDate;

  IndianGoldRateModel({
    required this.price24kPerGram,
    required this.price22kPerGram,
    required this.price18kPerGram,
    required this.timestamp,
    required this.source,
    required this.unit,
    this.purity999,
    this.purity916,
    this.purity750,
    required this.session,
    required this.rateDate,
  });

  factory IndianGoldRateModel.fromJson(Map<String, dynamic> json) {
    // API returns price per 10 grams, e.g., "152961"
    
    // Prefer PM if available, otherwise fallback to AM
    final String session = (json['lblGold999_PM'] != null) ? 'PM' : 'AM';
    final rateDate = json['date'] as String? ?? '';
    
    final purity999Raw = json['lblGold999_$session'];
    final purity916Raw = json['lblGold916_$session'];
    final purity750Raw = json['lblGold750_$session'];
    
    final p999 = _parseDouble(purity999Raw);
    final p916 = _parseDouble(purity916Raw);
    final p750 = _parseDouble(purity750Raw);

    return IndianGoldRateModel(
      price24kPerGram: p999 / 10.0,
      price22kPerGram: p916 / 10.0,
      price18kPerGram: p750 / 10.0,
      timestamp: DateTime.now().toIso8601String(),
      source: 'IBJA Benchmark',
      unit: 'INR/g',
      purity999: p999,
      purity916: p916,
      purity750: p750,
      session: session,
      rateDate: rateDate,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'price24kPerGram': price24kPerGram,
      'price22kPerGram': price22kPerGram,
      'price18kPerGram': price18kPerGram,
      'timestamp': timestamp,
      'source': source,
      'unit': unit,
      'purity999': purity999,
      'purity916': purity916,
      'purity750': purity750,
      'session': session,
      'rateDate': rateDate,
    };
  }
}
