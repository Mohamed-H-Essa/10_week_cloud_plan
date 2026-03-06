// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection.dart';

class ReflectionAdapter extends TypeAdapter<Reflection> {
  @override
  final int typeId = 4;

  @override
  Reflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reflection(
      weekNumber: fields[0] as int,
      wentWell: fields[1] as String,
      toImprove: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Reflection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weekNumber)
      ..writeByte(1)
      ..write(obj.wentWell)
      ..writeByte(2)
      ..write(obj.toImprove)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
