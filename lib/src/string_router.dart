import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';



// bool isSubtype<T1, T2>() => <T1>[] is List<T2>;

// typedef JsonList = List<Map<String, dynamic>>;
// typedef Json = Map<String, dynamic>;

// class KRequestOptions<T> {
//   final dynamic dataToSend;
//   final String? exportKey;
//   final Map<String, String>? headers;
//   final bool? ignoreResponse;
//   final T Function(Json item)? fromMap;
//   final Function(List<T>)? onMemory;

//   final ResponseType? responseType;
//   KRequestOptions({
//     this.dataToSend,
//     this.exportKey,
//     this.headers,
//     this.ignoreResponse,
//     this.fromMap,
//     this.onMemory,
//     this.responseType,
//   });
// }

// Future<T?> loadingWrapper<T>(
//   BuildContext context,
//   Future<T?> Function() request, {
//   void Function(T? data)? onDone,
//   Future<void> Function(String? e, StackTrace? stack)? customError,
//   bool displayDefaultMessage = true,
//   bool displayStack = true,
//   bool canGoToStart = true,
//   String? titleMessage,
//   String? message,
//   Widget? customAction,
//   bool showLoading = true,
// }) async {
//   try {
//     if (showLoading) kShowLoadingDialog();

//     final data = await request();
//     onDone?.call(data);
//     return data;
//   } catch (e, stack) {
//     if (e is String) {
//       if (e.startsWith('ignore')) {
//         debugPrint('[loadingWrapper]>> $e ignored');
//         await customError?.call(e.replaceAll('ignore-', ''), stack);
//       }
//       if (e.startsWith('show')) {
//         await showErrorDialog(
//           FlutterErrorDetails(exception: e, stack: stack),
//           title: titleMessage,
//           displayDefaultMessage: displayDefaultMessage,
//           displayStack: false,
//           canGoToStart: false,
//           message: e.replaceAll('show-', ''),
//           customAction: customAction,
//         );
//       }
//       if (e.startsWith('snack')) {
//         kShowScaffoldSnackBar(context, e.replaceAll('snack-', ''));
//       }
//     } else {
//       if (customError != null) {
//         await customError.call(e.toString(), stack);
//       } else {
//         await showErrorDialog(
//           FlutterErrorDetails(exception: e, stack: stack),
//           title: titleMessage,
//           displayDefaultMessage: displayDefaultMessage,
//           displayStack: displayStack,
//           canGoToStart: canGoToStart,
//           message: message,
//         );
//       }
//     }
//   } finally {
//     if (showLoading) {
//       KNavigator().pop();
//     }
//   }
//   return null;
// }

// extension EndPoint on String {
//   Future<List<R>?> put<R>(KRequestOptions<R> options) async {
//     final client = GetIt.I.get<AppClientProvider>();

//     Future clientMethod() => client.put(
//       this,
//       options.dataToSend,
//       responseType: options.responseType,
//       exportKey: options.exportKey ?? 'data',
//       ignoreResponse: options.ignoreResponse ?? true,
//       headers: options.headers,
//     );

//     return await _request(
//       options: options,
//       clientMethod: clientMethod,
//       route: this,
//     );
//   }

//   Future<List<R>?> delete<R>([KRequestOptions<R>? options]) async {
//     final client = GetIt.I.get<AppClientProvider>();

//     Future clientMethod() => client.delete(
//       this,
//       responseType: options?.responseType,
//       exportKey: options?.exportKey ?? 'data',
//       ignoreResponse: options?.ignoreResponse ?? true,
//       headers: options?.headers,
//     );

//     return await _request(
//       options: options,
//       clientMethod: clientMethod,
//       route: this,
//     );
//   }

//   Future<List<R>?> post<R>(KRequestOptions<R> options) async {
//     final client = GetIt.I.get<AppClientProvider>();

//     Future clientMethod() => client.post(
//       this,
//       options.dataToSend,
//       responseType: options.responseType,
//       exportKey: options.exportKey ?? 'data',
//       ignoreResponse: options.ignoreResponse ?? true,
//       headers: options.headers,
//     );

//     return await _request(
//       options: options,
//       clientMethod: clientMethod,
//       route: this,
//     );
//   }

//   Future<List<R>> get<R>([KRequestOptions<R>? options]) async {
//     final client = GetIt.I.get<AppClientProvider>();

//     debugPrint('[router]>> get $this');

//     Future clientMethod() => client.get(
//       this,
//       exportKey: options?.exportKey ?? 'data',
//       headers: options?.headers,
//       responseType: options?.responseType,
//     );

//     return await _request(
//           options: options,
//           clientMethod: clientMethod,
//           route: this,
//         ) ??
//         [];
//   }

//   Future<List<R>?> _request<R>({
//     required Future Function() clientMethod,
//     KRequestOptions<R>? options,
//     String? route,
//   }) async {
//     final handler = HandleRequestResponse<R>();
//     try {
//       final data = await clientMethod();

//       return handler.convertTypes(data, options?.fromMap);
//     } catch (e) {
//       if (e is RequestError) rethrow;
//       return await handler.readMemoryBeforeError(e, options?.onMemory, route);
//     }
//   }
// }

// class HandleRequestResponse<R> {
//   List<R> convertTypes(
//     dynamic data,
//     R Function(Map<String, dynamic> item)? fromMap,
//   ) {
//     if (isSubtype<R, JsonList>() || isSubtype<R, Json>()) {
//       return data;
//     }

//     if (fromMap != null) {
//       if (data is List) {
//         return data.map<R>((e) => fromMap(e)).toList();
//       } else {
//         return [fromMap(data)];
//       }
//     }

//     debugPrint('[handler]>> return data as special type ${data.runtimeType}');
//     if (data is List<R>) return data;

//     return [data];
//   }

//   Future<List<R>> readMemoryBeforeError(e, onMemory, route) async {
//     if (!isSubtype<R, JsonList>() && !isSubtype<R, Json>()) {
//       final memory2 = HiveCustomService<R>(
//         boxName:
//             '${R.toString()[0].toLowerCase() + R.toString().substring(1)}-offline',
//       );
//       final data2 = await memory2.getAllItems();
//       if (data2.isNotEmpty) {
//         debugPrint('[memoryHandle]>> WARNING \n$this\n from memory ---->');
//         return onMemory?.call(data2) ?? data2;
//       }
//     }
//     if (e is DioException) {
//       throw {
//         'message': e.response?.data['Error'],
//         'debugMessage': "$route -- ${e.response}",
//         'status': e.response?.statusCode,
//       };
//     } else {
//       throw {'debugMessage': e.toString(), 'status': 500};
//     }
//   }
// }

// class RequestError {
//   final String? message;
//   final String? debugMessage;

//   RequestError({this.message, this.debugMessage});
// }

// class ConnectionError {
//   final String? message;
//   final String? debugMessage;
//   final int? status;

//   ConnectionError({this.status, this.message, this.debugMessage});
// }

// class TypeConversionError {
//   final String? message;
//   final String? debugMessage;

//   TypeConversionError({this.message, this.debugMessage});
// }
