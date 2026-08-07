// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_price_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoldPriceModelAdapter extends TypeAdapter<GoldPriceModel> {
  @override
  final int typeId = 0;

  @override
  GoldPriceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoldPriceModel(
      currency: fields[0] as String,
      timestamp: fields[1] as String,
      priceGram24k: fields[2] as double,
      priceGram22k: fields[3] as double,
      priceGram21k: fields[4] as double,
      priceGram20k: fields[5] as double,
      priceGram18k: fields[6] as double,
      priceGram16k: fields[7] as double,
      priceGram14k: fields[8] as double,
      priceGram10k: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GoldPriceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.priceGram24k)
      ..writeByte(3)
      ..write(obj.priceGram22k)
      ..writeByte(4)
      ..write(obj.priceGram21k)
      ..writeByte(5)
      ..write(obj.priceGram20k)
      ..writeByte(6)
      ..write(obj.priceGram18k)
      ..writeByte(7)
      ..write(obj.priceGram16k)
      ..writeByte(8)
      ..write(obj.priceGram14k)
      ..writeByte(9)
      ..write(obj.priceGram10k);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoldPriceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
