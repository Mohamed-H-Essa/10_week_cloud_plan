import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  static const _boxName = 'settings';
  static const _key = 'app_settings';

  late Box<AppSettings> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AppSettings>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, AppSettings());
    }
  }

  AppSettings get settings => _box.get(_key) ?? AppSettings();

  Future<void> save(AppSettings settings) async {
    await _box.put(_key, settings);
  }

  Future<void> update(void Function(AppSettings s) updater) async {
    final s = settings;
    updater(s);
    await s.save();
  }
}
