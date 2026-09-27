import 'package:hive/hive.dart';

class StorageService {
  static const String boxName = 'appnovasi_kit';

  Box<dynamic>? _box;

  Future<void> init() async {
    _box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
  }

  Box<dynamic> get box {
    final box = _box;
    if (box == null) {
      throw StateError(
        'StorageService is not initialized. Call AppKit.initialize first.',
      );
    }
    return box;
  }

  T? read<T>(String key) => box.get(key) as T?;

  Future<void> write(String key, Object? value) => box.put(key, value);

  Future<void> delete(String key) => box.delete(key);

  Future<void> clear() => box.clear();
}
