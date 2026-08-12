// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indian_gold_rate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IndianGoldRateModelAdapter extends TypeAdapter<IndianGoldRateModel> {
  @override
  final int typeId = 2;

  @override
  IndianGoldRateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndianGoldRateModel(
      price24kPerGram: fields[0] as double,
      price22kPerGram: fields[1] as double,
      price18kPerGram: fields[2] as double,
      timestamp: fields[3] as String,
      source: fields[4] as String,
      unit: fields[5] as String,
      purity999: fields[6] as double?,
      purity916: fields[7] as double?,
      purity750: fields[8] as double?,
      session: fields[9] as String,
      rateDate: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IndianGoldRateModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.price24kPerGram)
      ..writeByte(1)
      ..write(obj.price22kPerGram)
      ..writeByte(2)
      ..write(obj.price18kPerGram)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.purity999)
      ..writeByte(7)
      ..write(obj.purity916)
      ..writeByte(8)
      ..write(obj.purity750)
      ..writeByte(9)
      ..write(obj.session)
      ..writeByte(10)
      ..write(obj.rateDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndianGoldRateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
