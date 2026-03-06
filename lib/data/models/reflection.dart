import 'package:hive/hive.dart';

part 'reflection.g.dart';

@HiveType(typeId: 4)
class Reflection extends HiveObject {
  @HiveField(0)
  final int weekNumber;

  @HiveField(1)
  String wentWell;

  @HiveField(2)
  String toImprove;

  @HiveField(3)
  final DateTime createdAt;

  Reflection({
    required this.weekNumber,
    required this.wentWell,
    required this.toImprove,
    required this.createdAt,
  });
}
