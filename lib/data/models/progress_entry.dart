import 'package:hive/hive.dart';

part 'progress_entry.g.dart';

@HiveType(typeId: 2)
class ProgressEntry extends HiveObject {
  @HiveField(0)
  final String taskId;

  @HiveField(1)
  final int weekNumber;

  @HiveField(2)
  final DateTime completedAt;

  ProgressEntry({
    required this.taskId,
    required this.weekNumber,
    required this.completedAt,
  });
}
