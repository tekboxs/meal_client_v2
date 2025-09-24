import 'package:meal_client_v2/meal_client_v2.dart';

void main() async {
  print('=== Meal Client V2 Database Example ===\n');

  // Initialize database
  await DatabaseManager.initialize(path: './test_db');
  print('✅ Database initialized\n');

  // Example 1: Using enum extensions for cache operations
  print('1. Cache Operations with Extensions:');
  await CacheKeys.userData.save({'name': 'John', 'age': 30});
  await CacheKeys.apiResponse.save(
    {'data': 'some api data'},
    expiration: Duration(minutes: 10),
  );
//Slv tek//
  final userData = await CacheKeys.userData.read<Map<String, dynamic>>();
  print('   User data: $userData');

  final exists = await CacheKeys.userData.exists();
  print('   User data exists: $exists\n');

  // Example 2: Using enum extensions for config operations
  print('2. Config Operations with Extensions:');
  await ConfigKeys.token.save('abc123token');
  await ConfigKeys.baseUrl.save('https://api.example.com');

  final token = await ConfigKeys.token.read<String>();
  print('   Token: $token');

  final baseUrl = await ConfigKeys.baseUrl.read<String>();
  print('   Base URL: $baseUrl\n');

  // Example 3: Using DatabaseService directly
  print('3. Direct DatabaseService Usage:');
  final databaseService = DatabaseManager.databaseService;

  await databaseService.saveCache('custom_key', {'custom': 'data'});
  final customData =
      await databaseService.getCache<Map<String, dynamic>>('custom_key');
  print('   Custom data: $customData');

  await databaseService.saveConfig('custom_config', 'custom_value');
  final customConfig = await databaseService.getConfig<String>('custom_config');
  print('   Custom config: $customConfig\n');

  // Example 4: Using DatabaseContainer for dependency injection
  print('4. DatabaseContainer Usage:');

  // Get services from container
  final cacheService = DatabaseContainer.cacheService;
  final configService = DatabaseContainer.configService;

  print('   Cache service is open: ${cacheService.isOpen}');
  print('   Config service is open: ${configService.isOpen}');

  // Use services from container
  await cacheService.write('container_key', 'container_value');
  final containerValue = await cacheService.read<String>('container_key');
  print('   Container value: $containerValue\n');

  // Example 5: Utility operations
  print('5. Utility Operations:');
  final allCacheKeys = await databaseService.getAllCacheKeys();
  print('   All cache keys: $allCacheKeys');

  final allConfigKeys = await databaseService.getAllConfigKeys();
  print('   All config keys: $allConfigKeys');

  // Clear expired cache
  await databaseService.clearExpiredCache();
  print('Expired cache cleared\n');

  // Example 6: Cache expiration demonstration
  print('6. Cache Expiration Demo:');
  await databaseService.saveCache('temp_data', 'This will expire',
      expiration: Duration(seconds: 1));
  print('   Saved temporary data');

  await Future.delayed(Duration(seconds: 2));
  final expiredData = await databaseService.getCache<String>('temp_data');
  print('   Expired data: $expiredData (should be null)\n');

  // Example 7: Bulk operations
  print('7. Bulk Operations:');
  await databaseService.saveCache('bulk_1', 'data1');
  await databaseService.saveCache('bulk_2', 'data2');
  await databaseService.saveConfig('bulk_config_1', 'config1');
  await databaseService.saveConfig('bulk_config_2', 'config2');

  final allKeys = await databaseService.getAllCacheKeys();
  final allConfigs = await databaseService.getAllConfigKeys();
  print('   Cache keys after bulk save: $allKeys');
  print('   Config keys after bulk save: $allConfigs\n');

  // Cleanup
  print('8. Cleanup:');
  await DatabaseManager.dispose();
  print('Database disposed\n');

  print('=== Finish ===');
}
