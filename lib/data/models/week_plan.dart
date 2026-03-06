import 'package:hive/hive.dart';
import 'task_item.dart';

part 'week_plan.g.dart';

@HiveType(typeId: 0)
class WeekPlan extends HiveObject {
  @HiveField(0)
  final int weekNumber;

  @HiveField(1)
  final String phase;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final String tagline;

  @HiveField(5)
  final String why;

  @HiveField(6)
  List<TaskItem> fridayTasks;

  @HiveField(7)
  List<TaskItem> saturdayTasks;

  @HiveField(8)
  final String weeknightSaa;

  @HiveField(9)
  final String weeknightSchedule;

  @HiveField(10)
  final String cost;

  @HiveField(11)
  final String output;

  @HiveField(12)
  final String linkedinPost;

  @HiveField(13)
  final String linkedinAngle;

  @HiveField(14)
  String quickNote;

  WeekPlan({
    required this.weekNumber,
    required this.phase,
    required this.title,
    required this.color,
    required this.tagline,
    required this.why,
    required this.fridayTasks,
    required this.saturdayTasks,
    required this.weeknightSaa,
    required this.weeknightSchedule,
    required this.cost,
    required this.output,
    required this.linkedinPost,
    required this.linkedinAngle,
    this.quickNote = '',
  });
}
