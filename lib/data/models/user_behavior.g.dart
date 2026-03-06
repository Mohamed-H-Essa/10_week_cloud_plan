// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_behavior.dart';

class UserBehaviorAdapter extends TypeAdapter<UserBehavior> {
  @override
  final int typeId = 5;

  @override
  UserBehavior read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserBehavior(
      lastAppOpen: fields[0] as DateTime?,
      lastTaskCompletion: fields[1] as DateTime?,
      activeHours: (fields[2] as List?)?.cast<int>() ?? List.filled(24, 0),
      appOpenHistory: (fields[3] as List?)?.cast<DateTime>() ?? [],
      taskCompletionHistory: (fields[4] as List?)?.cast<DateTime>() ?? [],
      consecutiveIgnoredDays: fields[5] as int? ?? 0,
      lastNotificationMood: fields[6] as String?,
      lastScheduleRun: fields[7] as DateTime?,
      comebackMessagesSent: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserBehavior obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.lastAppOpen)
      ..writeByte(1)
      ..write(obj.lastTaskCompletion)
      ..writeByte(2)
      ..write(obj.activeHours)
      ..writeByte(3)
      ..write(obj.appOpenHistory)
      ..writeByte(4)
      ..write(obj.taskCompletionHistory)
      ..writeByte(5)
      ..write(obj.consecutiveIgnoredDays)
      ..writeByte(6)
      ..write(obj.lastNotificationMood)
      ..writeByte(7)
      ..write(obj.lastScheduleRun)
      ..writeByte(8)
      ..write(obj.comebackMessagesSent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
