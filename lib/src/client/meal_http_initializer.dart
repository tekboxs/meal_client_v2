import 'package:dio/dio.dart';
import 'package:meal_client_v2/meal_client_v2.dart';
import 'package:meal_client_v2/src/client/meal_interceptors.dart';

class MealInitializer {
  final MealInterceptors interceptors;
  MealInitializer(this.interceptors);

  Future<Dio> call() async {
    final baseUrl = await ConfigKeys.baseUrl.read<String>() ?? '';
    final receiveTimeoutSeconds = await ConfigKeys.receiveTimeout.read<int>() ??
        NumberStandard.receiveTimeout.value;
    final sendTimeoutSeconds = await ConfigKeys.sendTimeout.read<int>() ??
        NumberStandard.sendTimeout.value;
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: receiveTimeoutSeconds),
        receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
        sendTimeout: Duration(seconds: sendTimeoutSeconds),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(interceptors);

    return dio;
  }

  Dio customInit() {
    return Dio();
  }
}
