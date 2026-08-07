import 'package:hive/hive.dart';
import 'package:aurum/data/models/gold_price_model.dart';

part 'gold_history_model.g.dart';

@HiveType(typeId: 1)
class GoldHistoryModel {
  @HiveField(0)
  final GoldPriceModel goldPrice;

  @HiveField(1)
  final String fetchTimestamp;

  GoldHistoryModel({
    required this.goldPrice,
    required this.fetchTimestamp,
  });

  factory GoldHistoryModel.fromJson(Map<String, dynamic> json) {
    return GoldHistoryModel(
      goldPrice: GoldPriceModel.fromJson(json['goldPrice'] ?? {}),
      fetchTimestamp: json['fetchTimestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goldPrice': goldPrice.toJson(),
      'fetchTimestamp': fetchTimestamp,
    };
  }
}
