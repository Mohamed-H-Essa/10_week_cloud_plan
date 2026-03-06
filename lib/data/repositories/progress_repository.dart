import 'package:hive/hive.dart';
import '../models/progress_entry.dart';

class ProgressRepository {
  static const _boxName = 'progress';

  late Box<ProgressEntry> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ProgressEntry>(_boxName);
  }

  bool isCompleted(String taskId) {
    return _box.values.any((e) => e.taskId == taskId);
  }

  Set<String> completedTaskIds() {
    return _box.values.map((e) => e.taskId).toSet();
  }

  List<ProgressEntry> entriesForWeek(int weekNumber) {
    return _box.values.where((e) => e.weekNumber == weekNumber).toList();
  }

  List<ProgressEntry> allEntries() => _box.values.toList();

  Future<void> toggleTask(String taskId, int weekNumber) async {
    final existing = _box.values.where((e) => e.taskId == taskId).toList();
    if (existing.isNotEmpty) {
      for (final e in existing) {
        await e.delete();
      }
    } else {
      await _box.add(ProgressEntry(
        taskId: taskId,
        weekNumber: weekNumber,
        completedAt: DateTime.now(),
      ));
    }
  }

  int completedCountForWeek(int weekNumber, List<String> taskIds) {
    final completed = completedTaskIds();
    return taskIds.where((id) => completed.contains(id)).length;
  }

  double weekProgress(int weekNumber, List<String> allTaskIds) {
    if (allTaskIds.isEmpty) return 0;
    return completedCountForWeek(weekNumber, allTaskIds) / allTaskIds.length;
  }

  int get totalCompleted => _box.length;
}
