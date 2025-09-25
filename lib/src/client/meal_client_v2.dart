import 'package:dio/dio.dart';
import 'package:dio/src/options.dart';
import 'package:meal_client_v2/src/client/meal_db_adapter.dart';
import 'package:meal_client_v2/src/client/meal_dio_initializer.dart';
import 'package:retry/retry.dart';

enum MealClientError { notFound, invalidResponse }

class MealClientV2{
  final MealDioInitializer initializer;
  //TODO: Nao entendi o IMealDBAdpter
  MealClientDBAdapter adapter = MealClientDBAdapter();
  MealClientV2({required this.initializer});

  String _cacheKey(String base, String patch) {
    return Uri.parse(base).resolve(patch).toString();
  }

  Future<dynamic> _cacheHandle(String? url) async {
    if (url == null) return null;
    final data = await adapter.read(Uri.parse(url), ignoreCache: false);
    if (data is! MealDataBaseError) {
      print(">> send data from cache");
      return data;
    }
    return null;
  }

  dynamic _defaultSelection(
    Response? response,
    String defaultKeySelector, {
    dynamic cacheData,
  }) {
    if (response != null && response.data is Map) {
      final map = response.data as Map;
      if (map.containsKey(defaultKeySelector)) {
        return map[defaultKeySelector];
      }
    }
    if (cacheData != null && cacheData is Map) {
      if (cacheData.containsKey(defaultKeySelector)) {
        return cacheData[defaultKeySelector];
      }
    }
    print(">> default key not found");
    //TODO: HELP por que assim ?? ?? ??
    return response?.data ?? cacheData ?? MealClientError.invalidResponse;
  }

  bool _isRetriable(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
    }
    return false;
  }

  Future getMethod(
    String url, {
    Map<String, String>? headers,
    ResponseType? responseType,
    bool enableCache = false,
    String defaultKeySelector = 'data',
  }) async {
    final key = _cacheKey(initializer.varBaseUrl, url);
    // habilitar cache
    if (enableCache) {
      final cachedData = await _cacheHandle(key);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultKeySelector,
          cacheData: cachedData,
        );
      }
    }

    // Rede com retry
    try {
      final dio = initializer();
      final response = await RetryOptions(maxAttempts: 3).retry(
        () async {
          final resp = await dio.get(url,
              options: Options(
                responseType: responseType ?? ResponseType.json,
                headers: headers ?? const <String, String>{},
                receiveTimeout: const Duration(seconds: 5),
                sendTimeout: const Duration(seconds: 5),
              ));
          return resp;
        },
        retryIf: _isRetriable,
      );
      // Gravar no cache
      try {
        adapter.save(key, response.data);
      } catch (_) {
        print(">> eror ao salvar cache");
      }
      //  Selecao de chave
      if (defaultKeySelector.isNotEmpty) {
        return _defaultSelection(response, defaultKeySelector);
      } else {
        return response.data;
      }
    } catch (e) {
      final cachedData = await _cacheHandle(key);
      if (cachedData != null && cachedData is! MealDataBaseError) {
        return _defaultSelection(
          null,
          defaultKeySelector,
          cacheData: cachedData,
        );
      }
      return MealClientError.notFound;
    }
  }

  Future postMethod(
    String url,
    data, {
    Map<String, String>? headers,
    ResponseType? responseType,
  }) async {
    final dio = initializer();
    final resp = await dio.post(
      url,
      data: data,
      options: Options(
        headers: headers ?? const <String, String>{},
        responseType: responseType ?? ResponseType.json,
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );
    return resp.data;
  }
}
