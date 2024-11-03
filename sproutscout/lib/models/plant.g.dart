// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 0;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      name: fields[0] as String,
      lastWetTime: fields[1] as DateTime,
      isMoistureHigh: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lastWetTime)
      ..writeByte(2)
      ..write(obj.isMoistureHigh);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
