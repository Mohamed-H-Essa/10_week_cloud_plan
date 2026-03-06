// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_plan.dart';

class WeekPlanAdapter extends TypeAdapter<WeekPlan> {
  @override
  final int typeId = 0;

  @override
  WeekPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeekPlan(
      weekNumber: fields[0] as int,
      phase: fields[1] as String,
      title: fields[2] as String,
      color: fields[3] as String,
      tagline: fields[4] as String,
      why: fields[5] as String,
      fridayTasks: (fields[6] as List).cast<TaskItem>(),
      saturdayTasks: (fields[7] as List).cast<TaskItem>(),
      weeknightSaa: fields[8] as String,
      weeknightSchedule: fields[9] as String,
      cost: fields[10] as String,
      output: fields[11] as String,
      linkedinPost: fields[12] as String,
      linkedinAngle: fields[13] as String,
      quickNote: fields[14] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, WeekPlan obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.weekNumber)
      ..writeByte(1)
      ..write(obj.phase)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.tagline)
      ..writeByte(5)
      ..write(obj.why)
      ..writeByte(6)
      ..write(obj.fridayTasks)
      ..writeByte(7)
      ..write(obj.saturdayTasks)
      ..writeByte(8)
      ..write(obj.weeknightSaa)
      ..writeByte(9)
      ..write(obj.weeknightSchedule)
      ..writeByte(10)
      ..write(obj.cost)
      ..writeByte(11)
      ..write(obj.output)
      ..writeByte(12)
      ..write(obj.linkedinPost)
      ..writeByte(13)
      ..write(obj.linkedinAngle)
      ..writeByte(14)
      ..write(obj.quickNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeekPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
