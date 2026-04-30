// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonorHiveModelAdapter extends TypeAdapter<DonorHiveModel> {
  @override
  final int typeId = 10;

  @override
  DonorHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DonorHiveModel(
      uid: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      totalDonated: fields[3] as double,
      donationsCount: fields[4] as int,
      casesSupportedCount: fields[5] as int,
      paymentType: fields[6] as String?,
      vodafoneNumber: fields[7] as String?,
      cardToken: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DonorHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.totalDonated)
      ..writeByte(4)
      ..write(obj.donationsCount)
      ..writeByte(5)
      ..write(obj.casesSupportedCount)
      ..writeByte(6)
      ..write(obj.paymentType)
      ..writeByte(7)
      ..write(obj.vodafoneNumber)
      ..writeByte(8)
      ..write(obj.cardToken)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonorHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
