// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      weeknightNotificationsEnabled: fields[0] as bool? ?? false,
      weeknightNotificationHour: fields[1] as int? ?? 20,
      weeknightNotificationMinute: fields[2] as int? ?? 0,
      weekendNotificationsEnabled: fields[3] as bool? ?? false,
      weekendNotificationHour: fields[4] as int? ?? 9,
      weekendNotificationMinute: fields[5] as int? ?? 0,
      calendarId: fields[6] as String?,
      pomodoroMinutes: fields[7] as int? ?? 25,
      shortBreakMinutes: fields[8] as int? ?? 5,
      longBreakMinutes: fields[9] as int? ?? 15,
      planStartDate: fields[10] as DateTime?,
      darkModeOverride: fields[11] as bool?,
      midSessionNotificationsEnabled: fields[12] as bool? ?? false,
      smartNotificationsEnabled: fields[13] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.weeknightNotificationsEnabled)
      ..writeByte(1)
      ..write(obj.weeknightNotificationHour)
      ..writeByte(2)
      ..write(obj.weeknightNotificationMinute)
      ..writeByte(3)
      ..write(obj.weekendNotificationsEnabled)
      ..writeByte(4)
      ..write(obj.weekendNotificationHour)
      ..writeByte(5)
      ..write(obj.weekendNotificationMinute)
      ..writeByte(6)
      ..write(obj.calendarId)
      ..writeByte(7)
      ..write(obj.pomodoroMinutes)
      ..writeByte(8)
      ..write(obj.shortBreakMinutes)
      ..writeByte(9)
      ..write(obj.longBreakMinutes)
      ..writeByte(10)
      ..write(obj.planStartDate)
      ..writeByte(11)
      ..write(obj.darkModeOverride)
      ..writeByte(12)
      ..write(obj.midSessionNotificationsEnabled)
      ..writeByte(13)
      ..write(obj.smartNotificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
