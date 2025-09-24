import '../models/cache_model.dart';
import '../models/config_model.dart';
import '../services/hive_service.dart';

class DatabaseService {
  final HiveService _cacheService;
  final HiveService _configService;
  final Duration defaultExpiration;

  DatabaseService({
    required HiveService cacheService,
    required HiveService configService,
    this.defaultExpiration = const Duration(hours: 8),
  }) : _cacheService = cacheService, _configService = configService;

  Future<void> init() async {
    await _cacheService.init();
    await _configService.init();
  }

  // Cache methods with expiration
  Future<void> saveCache(String key, dynamic value, {Duration? expiration}) async {
    final cacheModel = CacheModel(value: value);
    final expirationDuration = expiration ?? defaultExpiration;
    
    await _cacheService.write(key, {
      'data': cacheModel.toMap(),
      'expiration': expirationDuration.inMilliseconds,
    });
  }

  Future<T?> getCache<T>(String key) async {
    final data = await _cacheService.read<Map>(key);
    if (data == null) return null;

    final cacheModel = CacheModel.fromMap(data['data'] as Map<String, dynamic>);
    final expiration = Duration(milliseconds: data['expiration'] as int);

    if (_isCacheExpired(cacheModel, expiration)) {
      await deleteCache(key);
      return null;
    }

    return cacheModel.value as T?;
  }

  Future<void> deleteCache(String key) async {
    await _cacheService.delete(key);
  }

  Future<bool> cacheExists(String key) async {
    final data = await _cacheService.read<Map>(key);
    if (data == null) return false;

    final cacheModel = CacheModel.fromMap(data['data'] as Map<String, dynamic>);
    final expiration = Duration(milliseconds: data['expiration'] as int);

    if (_isCacheExpired(cacheModel, expiration)) {
      await deleteCache(key);
      return false;
    }

    return true;
  }

  // Config methods without expiration
  Future<void> saveConfig(String key, dynamic value) async {
    final configModel = ConfigModel(
      key: key,
      value: value,
    );
    
    await _configService.write(key, configModel.toMap());
  }

  Future<T?> getConfig<T>(String key) async {
    final data = await _configService.read<Map>(key);
    if (data == null) return null;

    final configModel = ConfigModel.fromMap(Map<String, dynamic>.from(data));
    return configModel.value as T?;
  }

  Future<void> deleteConfig(String key) async {
    await _configService.delete(key);
  }

  Future<bool> configExists(String key) async {
    return await _configService.containsKey(key);
  }

  // Utility methods
  Future<void> clearCache() async {
    await _cacheService.clear();
  }

  Future<void> clearConfig() async {
    await _configService.clear();
  }

  Future<void> clearAll() async {
    await clearCache();
    await clearConfig();
  }

  Future<List<String>> getAllCacheKeys() async {
    return await _cacheService.getAllKeys();
  }

  Future<List<String>> getAllConfigKeys() async {
    return await _configService.getAllKeys();
  }

  Future<void> clearExpiredCache() async {
    final allData = await _cacheService.getAllData();
    final expiredKeys = <String>[];

    for (final entry in allData.entries) {
      final data = entry.value;
      
      // Only process data that follows the cache format with expiration
      if (data is Map && data.containsKey('data') && data.containsKey('expiration')) {
        try {
          final cacheModel = CacheModel.fromMap(data['data'] as Map<String, dynamic>);
          final expiration = Duration(milliseconds: data['expiration'] as int);

          if (_isCacheExpired(cacheModel, expiration)) {
            expiredKeys.add(entry.key);
          }
        } catch (e) {
          // Skip invalid cache entries
          continue;
        }
      }
    }

    for (final key in expiredKeys) {
      await deleteCache(key);
    }
  }

  bool _isCacheExpired(CacheModel cacheModel, Duration expiration) {
    return cacheModel.isExpired(expiration);
  }
}
