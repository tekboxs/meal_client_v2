import 'package:dio/dio.dart';
import 'package:meal_client_v2/meal_client_v2.dart';
import 'package:meal_client_v2/src/client/meal_interceptors.dart';

class MealInitializer {
  final MealInterceptors interceptors;
  MealInitializer(this.interceptors);
  

  Future<Dio> call() async{
    final baseUrl = await ConfigKeys.baseUrl.read<String>() ?? '';
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
