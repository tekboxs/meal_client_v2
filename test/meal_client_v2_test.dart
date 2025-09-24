import 'package:test/test.dart';
import 'package:meal_client_v2/meal_client_v2.dart';

void main() {
  group('Database Tests', () {
    test('should create cache model', () {
      final cacheModel = CacheModel(value: 'test_value');
      
      expect(cacheModel.value, equals('test_value'));
      expect(cacheModel.creationDate, isA<DateTime>());
    });

    test('should create config model', () {
      final configModel = ConfigModel(
        key: 'test_key',
        value: 'test_value',
      );
      
      expect(configModel.key, equals('test_key'));
      expect(configModel.value, equals('test_value'));
    });

    test('should check cache expiration', () {
      final cacheModel = CacheModel(value: 'test_value');
      final shortDuration = Duration(milliseconds: 1);
      final longDuration = Duration(hours: 1);
      
      expect(cacheModel.isExpired(shortDuration), isFalse);
      
      final oldCacheModel = CacheModel(
        value: 'test_value',
        creationDate: DateTime.now().subtract(Duration(hours: 2)),
      );
      
      expect(oldCacheModel.isExpired(longDuration), isTrue);
    });

    test('should have correct enum values', () {
      expect(CacheKeys.userData.key, equals('user_data'));
      expect(ConfigKeys.token.key, equals('token'));
      expect(DatabaseBoxes.cache.name, equals('cache_box'));
      expect(DatabaseBoxes.config.name, equals('config_box'));
    });

    test('should serialize and deserialize cache model', () {
      final originalModel = CacheModel(value: {'name': 'John', 'age': 30});
      final json = originalModel.toJson();
      final deserializedModel = CacheModel.fromJson(json);
      
      expect(deserializedModel.value, equals(originalModel.value));
      expect(deserializedModel.creationDate.millisecondsSinceEpoch, 
             equals(originalModel.creationDate.millisecondsSinceEpoch));
    });

    test('should copy cache model with new values', () {
      final originalModel = CacheModel(value: 'original');
      final copiedModel = originalModel.copyWith(value: 'copied');
      
      expect(copiedModel.value, equals('copied'));
      expect(copiedModel.creationDate, equals(originalModel.creationDate));
    });

    test('should copy config model with new values', () {
      final originalModel = ConfigModel(key: 'test', value: 'original');
      final copiedModel = originalModel.copyWith(value: 'copied');
      
      expect(copiedModel.key, equals('test'));
      expect(copiedModel.value, equals('copied'));
    });

    test('should have all required cache keys', () {
      expect(CacheKeys.userData.key, equals('user_data'));
      expect(CacheKeys.apiResponse.key, equals('api_response'));
      expect(CacheKeys.settings.key, equals('settings'));
      expect(CacheKeys.tempData.key, equals('temp_data'));
    });

    test('should have all required config keys', () {
      expect(ConfigKeys.token.key, equals('token'));
      expect(ConfigKeys.baseUrl.key, equals('base_url'));
      expect(ConfigKeys.userId.key, equals('user_id'));
      expect(ConfigKeys.lastSync.key, equals('last_sync'));
      expect(ConfigKeys.preferences.key, equals('preferences'));
    });
  });
}