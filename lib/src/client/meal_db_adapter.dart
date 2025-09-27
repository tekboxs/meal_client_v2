import 'package:meal_client_v2/meal_client_v2.dart';
import 'package:meal_client_v2/src/database/services/hive_service.dart';

enum MealDataBaseError { notFound, outdated }

class MealClientDBAdapter {
  MealClientDBAdapter({HiveService? database})
      : _database = database ?? DatabaseContainer.cacheService;

  final HiveService _database;
  static const _cacheDuration = Duration(minutes: 30);

  Future<void> save(dynamic key, dynamic value) async {
    final storageKey = key.toString();
    await _database.write(
      storageKey,
      CacheModel(value: value).toJson(),
    );
  }

  Future<dynamic> read(dynamic key, {bool ignoreCache = true}) async {
    final storageKey = key.toString();
    final data = await _database.read<String>(storageKey);
    if (data == null) return MealDataBaseError.notFound;

    final cache = CacheModel.fromJson(data);
    if (ignoreCache) {
      return cache.value;
    }

    final ageMinutes = DateTime.now().difference(cache.creationDate).inMinutes;
    if (ageMinutes < _cacheDuration.inMinutes) {
      return cache.value;
    }

    return MealDataBaseError.outdated;
  }

  Future<void> delete(dynamic key) async {
    await _database.delete(key.toString());
  }
}
