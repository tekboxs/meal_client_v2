import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meal_client_v2/meal_client_v2.dart';
import 'package:test/test.dart';

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

  group('MealClient getMethod', () {
    late MealClient client;
    late _MockHttpClientAdapter adapter;
    final hiveDir = Directory('test/hive_boxes');

    setUpAll(() async {
      await hiveDir.create(recursive: true);
      await DatabaseManager.initialize(path: hiveDir.path);
    });

    tearDownAll(() async {
      await DatabaseManager.dispose();
      if (hiveDir.existsSync()) {
        await hiveDir.delete(recursive: true);
      }
    });

    setUp(() async {
      adapter = _MockHttpClientAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'))
        ..httpClientAdapter = adapter;

      final interceptors = MealInterceptors();
      final initializer = _TestMealInitializer(interceptors, dio);
      client = MealClient(initializer: initializer);

      await DatabaseManager.databaseService.clearAll();
      await ConfigKeys.baseUrl.save('https://api.test.com');
      await ConfigKeys.token.save('testToken');
      await ConfigKeys.receiveTimeout.save(3);
      await ConfigKeys.sendTimeout.save(3);
      await ConfigKeys.retryOptions.save(2);
    });

    tearDown(() async {
      await DatabaseManager.databaseService.clearAll();
    });

    test('returns response data and caches on success', () async {
      final result = await client.getMethod('/resource');

      expect(result, equals('freshData'));
      expect(adapter.callCount, equals(1));
      expect(
        adapter.lastRequestOptions?.headers['Authorization'],
        equals('Bearer testToken'),
      );

      final cached = await client.adapter.read('https://api.test.com');
      expect(cached, isA<Map>());
      expect((cached as Map)['data'], equals('freshData'));

      adapter.shouldFail = true;
      final cacheHit = await client.getMethod('/resource', enableCache: true);

      expect(cacheHit, equals('freshData'));
      expect(adapter.callCount, equals(1));
    });

    test('falls back to cached data when network fails', () async {
      await client.getMethod('/resource');
      adapter.shouldFail = true;

      final result = await client.getMethod('/resource', enableCache: false);

      expect(result, equals('freshData'));
      expect(adapter.callCount, equals(3));
    });
  });

  group('MealAuthenticator', () {
    late MealAuthenticator authenticator;
    late _MockHttpClientAdapter adapter;
    final hiveDir = Directory('test/hive_auth_boxes');

    setUpAll(() async {
      await hiveDir.create(recursive: true);
      await DatabaseManager.initialize(path: hiveDir.path);
    });

    tearDownAll(() async {
      await DatabaseManager.dispose();
      if (hiveDir.existsSync()) {
        await hiveDir.delete(recursive: true);
      }
    });

    setUp(() async {
      adapter = _MockHttpClientAdapter(
        responseMap: {
          'data': {
            'accessToken': _createJwt(
              user: 'user_a',
              account: 'acc_a',
              expiresIn: const Duration(minutes: 5),
            ),
          },
        },
      );

      final dio = Dio()..httpClientAdapter = adapter;
      authenticator = MealAuthenticator(
        baseUrl: 'https://api.test.com',
        username: 'user_a',
        password: 'secret',
        account: 'acc_a',
        httpClient: dio,
      );

      await DatabaseManager.databaseService.clearAll();
    });

    test('requests new token when none is stored', () async {
      final headers = await authenticator.getToken();

      expect(headers['Authorization'], startsWith('Bearer '));
      final storedToken = await ConfigKeys.token.read<String>();
      expect(storedToken, isNotNull);
      expect(adapter.callCount, equals(1));
    });

    test('reuses stored token when valid for current user and account', () async {
      final validToken = _createJwt(
        user: 'user_a',
        account: 'acc_a',
        expiresIn: const Duration(minutes: 5),
      );

      await ConfigKeys.token.save(validToken);

      adapter.shouldFail = true;

      final headers = await authenticator.getToken();

      expect(headers['Authorization'], equals('Bearer $validToken'));
      expect(adapter.callCount, equals(0));
    });

    test('cleans cache and refreshes token when account changes', () async {
      final cachedData = {'cached': 'value'};
      await CacheKeys.userData.save(cachedData);

      final mismatchedToken = _createJwt(
        user: 'user_a',
        account: 'other_account',
        expiresIn: const Duration(minutes: 5),
      );
      await ConfigKeys.token.save(mismatchedToken);

      final headers = await authenticator.getToken();

      expect(headers['Authorization'], isNotNull);
      expect(adapter.callCount, equals(1));
      final exists = await CacheKeys.userData.exists();
      expect(exists, isFalse);
    });
  });
}

String _createJwt({
  required String user,
  required String account,
  required Duration expiresIn,
}) {
  final header = {'alg': 'HS256', 'typ': 'JWT'};
  final expiry = DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  final payload = {
    'nameid': user,
    'groupsid': account,
    'exp': expiry,
  };

  String encode(Map<String, Object?> data) =>
      base64UrlEncode(utf8.encode(jsonEncode(data))).replaceAll('=', '');

  final headerPart = encode(header);
  final payloadPart = encode(payload);
  const signaturePart = 'signature';

  return '$headerPart.$payloadPart.$signaturePart';
}

class _TestMealInitializer extends MealInitializer {
  _TestMealInitializer(MealInterceptors interceptors, this._dio)
      : super(interceptors) {
    _dio.interceptors.add(interceptors);
  }

  final Dio _dio;

  @override
  Future<Dio> call() async {
    return _dio;
  }
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter({
    Map<String, dynamic>? responseMap,
  }) : responseMap = responseMap ?? const {'data': 'freshData'};

  final Map<String, dynamic> responseMap;
  bool shouldFail = false;
  int callCount = 0;
  RequestOptions? lastRequestOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    lastRequestOptions = options;

    if (shouldFail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
        error: 'Simulated failure',
      );
    }

    final payload = jsonEncode(responseMap);
    return ResponseBody.fromString(
      payload,
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }
}
