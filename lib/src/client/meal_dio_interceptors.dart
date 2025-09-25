import 'package:dio/dio.dart';
import 'package:meal_client_v2/meal_client_v2.dart';

class MealDioInterceptors {
  //Interceptores de retorno, usuario querer informacoes da api
  // Criando o header padrao da api
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (options.headers.isEmpty) {
      //TODO: Usar a classe MealAuthenticator
      final token = await ConfigKeys.token.read<String>();
      options.headers['Authorization'] = 'Bearer $token';
    }
    return options;
  }

  Response onResponse(Response response) {
    if (response.requestOptions.method == 'GET'){
      //TODO: adapter.save(response.request.uri, response.data);
    }
    return response;
  }
  DioException onError(DioException error) {
    // tratar erros
    return error;
  }
}
