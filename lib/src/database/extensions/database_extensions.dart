import '../core/database_manager.dart';
import '../enums/database_keys.dart';
import '../core/database_service.dart';

extension CacheKeysExtension on CacheKeys {
  DatabaseService get _service => DatabaseManager.databaseService;

  Future<void> save(dynamic value, {Duration? expiration}) async {
    await _service.saveCache(key, value, expiration: expiration);
  }

  Future<T?> read<T>() async {
    return await _service.getCache<T>(key);
  }

  Future<void> delete() async {
    await _service.deleteCache(key);
  }

  Future<bool> exists() async {
    return await _service.cacheExists(key);
  }
}

extension ConfigKeysExtension on ConfigKeys {
  DatabaseService get _service => DatabaseManager.databaseService;

  Future<void> save(dynamic value) async {
    await _service.saveConfig(key, value);
  }

  Future<T?> read<T>() async {
    return await _service.getConfig<T>(key);
  }

  Future<void> delete() async {
    await _service.deleteConfig(key);
  }

  Future<bool> exists() async {
    return await _service.configExists(key);
  }
}
