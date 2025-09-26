import 'package:meal_client_v2/meal_client_v2.dart';
import 'package:meal_client_v2/src/database/services/hive_service.dart';

enum MealDataBaseError { notFound, outdated }

class MealClientDBAdapter{
  final HiveService dataBase = HiveService(boxName: DatabaseBoxes.cache.name);

  void save(key, value) async {
    await dataBase.write(
      key,
      CacheModel(value: value).toJson(),
    );
    print(">> $key Saved");
  }

  Future read(key, {bool ignoreCache = true}) async {
    final data = await dataBase.read(key);
    if (data == null) return MealDataBaseError.notFound;
    if (ignoreCache) return CacheModel.fromJson(data).value;

    final cache = CacheModel.fromJson(data);
    final ageMinutes = DateTime.now().difference(cache.creationDate).inMinutes;

    if (ageMinutes < 30) {
      return cache.value;
    }
    return MealDataBaseError.outdated;
  }

  void delete(key) {
    // TODO: implement delete
  }

}
