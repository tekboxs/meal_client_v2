import 'package:dio/dio.dart';
import 'package:meal_client_v2/src/client/meal_dio_interceptors.dart';

class MealDioInitializer {
  final String varBaseUrl;
  final MealDioInterceptors interceptors;
  MealDioInitializer(this.varBaseUrl, this.interceptors);

  Dio call() {
    final dio = Dio(
      BaseOptions(
        baseUrl: varBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final opts = await interceptors.onRequest(options);
          handler.next(opts);
        },
        onResponse: (response, handler) {
          handler.next(interceptors.onResponse(response));
        },
        onError: (e, handler) {
          handler.next(interceptors.onError(e));
        },
      ),
    );

    return dio;
  }

  Dio customInit() {
    return Dio();
  }
}
