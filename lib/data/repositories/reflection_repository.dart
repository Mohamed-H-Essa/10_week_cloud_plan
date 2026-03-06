import 'package:hive/hive.dart';
import '../models/reflection.dart';

class ReflectionRepository {
  static const _boxName = 'reflections';

  late Box<Reflection> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Reflection>(_boxName);
  }

  Reflection? getForWeek(int weekNumber) {
    try {
      return _box.values.firstWhere((r) => r.weekNumber == weekNumber);
    } catch (_) {
      return null;
    }
  }

  List<Reflection> getAll() => _box.values.toList();

  bool hasReflection(int weekNumber) {
    return _box.values.any((r) => r.weekNumber == weekNumber);
  }

  Future<void> save(Reflection reflection) async {
    final existing = getForWeek(reflection.weekNumber);
    if (existing != null) {
      existing.wentWell = reflection.wentWell;
      existing.toImprove = reflection.toImprove;
      await existing.save();
    } else {
      await _box.add(reflection);
    }
  }
}
