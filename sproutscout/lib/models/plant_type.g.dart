// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantTypeAdapter extends TypeAdapter<PlantType> {
  @override
  final int typeId = 1;

  @override
  PlantType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantType(
      name: fields[0] as String,
      wateringFrequencySeconds: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PlantType obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.wateringFrequencySeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
