import 'package:hive/hive.dart';

class HiveService {
  final String boxName;
  Box? _box;

  HiveService({required this.boxName});

  bool get isOpen => _box?.isOpen ?? false;
  
  Box get _boxInstance {
    if (!isOpen) throw StateError('Box is not open. Call init() first.');
    return _box!;
  }

  Future<void> init() async {
    if (!isOpen) {
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> close() async {
    if (isOpen) {
      await _boxInstance.close();
    }
  }

  Future<void> clear() async {
    if (isOpen) {
      await _boxInstance.clear();
    }
  }

  Future<void> write(String key, dynamic value) async {
    if (!isOpen) await init();
    await _boxInstance.put(key, value);
  }

  Future<T?> read<T>(String key) async {
    if (!isOpen) await init();
    return _boxInstance.get(key) as T?;
  }

  Future<void> delete(String key) async {
    if (!isOpen) await init();
    await _boxInstance.delete(key);
  }

  Future<bool> containsKey(String key) async {
    if (!isOpen) await init();
    return _boxInstance.containsKey(key);
  }

  Future<List<String>> getAllKeys() async {
    if (!isOpen) await init();
    return _boxInstance.keys.cast<String>().toList();
  }

  Future<Map<String, dynamic>> getAllData() async {
    if (!isOpen) await init();
    return Map<String, dynamic>.from(_boxInstance.toMap());
  }
}
