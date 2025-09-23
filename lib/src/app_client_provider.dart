// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class AppClientProvider {
//   final Dio httpClient;
//   final Dio rawHttpClient = Dio();
//   AppClientProvider(this.httpClient);

//   dynamic _exportObjectData(dynamic object, String exportKey) {
//     ///not common object data, return all data
//     if (exportKey.isEmpty) return object;

//     ///normally response.data['data']
//     if (object is Map && object.containsKey(exportKey)) {
//       return object[exportKey];
//     }

//     ///cant find key means response has errors
//     throw '[_exportObjectData] >> cant export $object';
//   }

//   /// generalize to avoid creating multiples gets at this level
//   Future<T?> get<T>(
//     String route, {
//     Map<String, String>? headers,
//     String exportKey = 'data',
//     ResponseType? responseType,
//   }) async {
//     try {
//       Response? response;

//       if (route.startsWith('http')) {
//         ///if informed with http means not default API
//         response = await rawHttpClient.get(
//           route,
//           options: Options(responseType: responseType),
//         );
//       } else {
//         ///base route configured in Dio instance
//         response = await httpClient.get(
//           route,
//           options: Options(responseType: responseType),
//         );
//       }

//       if (response.statusCode == 200) {
//         return _exportObjectData(response.data, exportKey);
//       }

//       debugPrint('[AppClient]>> invalid status ${response.statusCode}');

//       throw 'invalid status ${response.statusCode}';
//     } catch (e) {
//       debugPrint('[AppClient]>> $route\n$e');
//       rethrow;
//     }
//   }

//   Future<T?> post<T>(
//     String route,
//     data, {
//     Map<String, String>? headers,
//     String exportKey = 'data',
//     bool ignoreResponse = true,
//     ResponseType? responseType,
//   }) async {
//     try {
//       Response? response;

//       if (route.startsWith('http')) {
//         response = await rawHttpClient.post(
//           route,
//           data: data,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       } else {
//         response = await httpClient.post(
//           route,
//           data: data,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       }

//       if (!ignoreResponse) return _exportObjectData(response.data, exportKey);

//       return null;
//     } catch (e) {
//       debugPrint('[AppClient]>> $route\n$e');

//       rethrow;
//     }
//   }

//   Future<T?> delete<T>(
//     String route, {
//     Map<String, String>? headers,
//     ResponseType? responseType,
//     bool ignoreResponse = true,
//     String exportKey = 'data',
//   }) async {
//     try {
//       Response? response;

//       if (route.startsWith('http')) {
//         response = await rawHttpClient.delete(
//           route,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       } else {
//         response = await httpClient.delete(
//           route,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       }

//       if (!ignoreResponse) return _exportObjectData(response.data, exportKey);

//       return null;
//     } catch (e) {
//       debugPrint('[AppClient]>> $route\n$e');

//       rethrow;
//     }
//   }

//   Future<T?> put<T>(
//     String route,
//     data, {
//     Map<String, String>? headers,
//     ResponseType? responseType,
//     bool ignoreResponse = true,
//     String exportKey = 'data',
//   }) async {
//     try {
//       Response? response;

//       if (route.startsWith('http')) {
//         response = await rawHttpClient.put(
//           route,
//           data: data,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       } else {
//         response = await httpClient.put(
//           route,
//           data: data,
//           options: Options(headers: headers, responseType: responseType),
//         );
//       }

//       if (!ignoreResponse) return _exportObjectData(response.data, exportKey);

//       return null;
//     } catch (e) {
//       debugPrint('[AppClient]>> $route\n$e');

//       rethrow;
//     }
//   }
// }
