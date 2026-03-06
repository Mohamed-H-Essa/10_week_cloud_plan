// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_entry.dart';

class ProgressEntryAdapter extends TypeAdapter<ProgressEntry> {
  @override
  final int typeId = 2;

  @override
  ProgressEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressEntry(
      taskId: fields[0] as String,
      weekNumber: fields[1] as int,
      completedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.weekNumber)
      ..writeByte(2)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
