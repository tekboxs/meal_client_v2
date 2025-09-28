import 'package:get_it/get_it.dart';
import '../services/hive_service.dart';
import 'database_service.dart';
import '../enums/database_keys.dart';

class DatabaseContainer {
  static final GetIt _container = GetIt.instance;

  static void registerServices() {
    _container.registerLazySingleton<HiveService>(
      () => HiveService(boxName: DatabaseBoxes.cache.name),
      instanceName: 'cache',
    );

    _container.registerLazySingleton<HiveService>(
      () => HiveService(boxName: DatabaseBoxes.config.name),
      instanceName: 'config',
    );

    _container.registerLazySingleton<DatabaseService>(
      () => DatabaseService(
        cacheService: _container.get<HiveService>(instanceName: 'cache'),
        configService: _container.get<HiveService>(instanceName: 'config'),
      ),
    );
  }

  static T get<T extends Object>() => _container.get<T>();

  static DatabaseService get databaseService => _container.get<DatabaseService>();
  static HiveService get cacheService => _container.get<HiveService>(instanceName: 'cache');
  static HiveService get configService => _container.get<HiveService>(instanceName: 'config');

  static Future<void> initAllServices() async {
    await databaseService.init();
  }

  static Future<void> closeAllServices() async {
    await cacheService.close();
    await configService.close();
  }

  static void reset() {
    _container.reset();
  }
}
