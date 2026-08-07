import 'package:hive/hive.dart';

part 'gold_price_model.g.dart';

@HiveType(typeId: 0)
class GoldPriceModel {
  @HiveField(0)
  final String currency;

  @HiveField(1)
  final String timestamp;

  @HiveField(2)
  final double priceGram24k;

  @HiveField(3)
  final double priceGram22k;

  @HiveField(4)
  final double priceGram21k;

  @HiveField(5)
  final double priceGram20k;

  @HiveField(6)
  final double priceGram18k;

  @HiveField(7)
  final double priceGram16k;

  @HiveField(8)
  final double priceGram14k;

  @HiveField(9)
  final double priceGram10k;

  GoldPriceModel({
    required this.currency,
    required this.timestamp,
    required this.priceGram24k,
    required this.priceGram22k,
    required this.priceGram21k,
    required this.priceGram20k,
    required this.priceGram18k,
    required this.priceGram16k,
    required this.priceGram14k,
    required this.priceGram10k,
  });

  factory GoldPriceModel.fromJson(Map<String, dynamic> json) {
    return GoldPriceModel(
      currency: json['currency'] ?? '',
      timestamp: json['timestamp'] ?? '',
      priceGram24k: _parseDouble(json['price_gram_24k']),
      priceGram22k: _parseDouble(json['price_gram_22k']),
      priceGram21k: _parseDouble(json['price_gram_21k']),
      priceGram20k: _parseDouble(json['price_gram_20k']),
      priceGram18k: _parseDouble(json['price_gram_18k']),
      priceGram16k: _parseDouble(json['price_gram_16k']),
      priceGram14k: _parseDouble(json['price_gram_14k']),
      priceGram10k: _parseDouble(json['price_gram_10k']),
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
      'currency': currency,
      'timestamp': timestamp,
      'price_gram_24k': priceGram24k.toString(),
      'price_gram_22k': priceGram22k.toString(),
      'price_gram_21k': priceGram21k.toString(),
      'price_gram_20k': priceGram20k.toString(),
      'price_gram_18k': priceGram18k.toString(),
      'price_gram_16k': priceGram16k.toString(),
      'price_gram_14k': priceGram14k.toString(),
      'price_gram_10k': priceGram10k.toString(),
    };
  }

  GoldPriceModel copyWith({
    String? currency,
    String? timestamp,
    double? priceGram24k,
    double? priceGram22k,
    double? priceGram21k,
    double? priceGram20k,
    double? priceGram18k,
    double? priceGram16k,
    double? priceGram14k,
    double? priceGram10k,
  }) {
    return GoldPriceModel(
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      priceGram24k: priceGram24k ?? this.priceGram24k,
      priceGram22k: priceGram22k ?? this.priceGram22k,
      priceGram21k: priceGram21k ?? this.priceGram21k,
      priceGram20k: priceGram20k ?? this.priceGram20k,
      priceGram18k: priceGram18k ?? this.priceGram18k,
      priceGram16k: priceGram16k ?? this.priceGram16k,
      priceGram14k: priceGram14k ?? this.priceGram14k,
      priceGram10k: priceGram10k ?? this.priceGram10k,
    );
  }
}
