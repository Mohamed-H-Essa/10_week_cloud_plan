import 'package:hive/hive.dart';

part 'task_item.g.dart';

@HiveType(typeId: 1)
class TaskItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  final String day; // "friday" or "saturday"

  @HiveField(3)
  final bool isCustom;

  @HiveField(4)
  int sortOrder;

  TaskItem({
    required this.id,
    required this.text,
    required this.day,
    this.isCustom = false,
    this.sortOrder = 0,
  });

  TaskItem copyWith({
    String? id,
    String? text,
    String? day,
    bool? isCustom,
    int? sortOrder,
  }) {
    return TaskItem(
      id: id ?? this.id,
      text: text ?? this.text,
      day: day ?? this.day,
      isCustom: isCustom ?? this.isCustom,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
