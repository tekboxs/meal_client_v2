import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meal_client_v2/meal_client_v2.dart';

class MealAuthenticationException implements Exception {
  const MealAuthenticationException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'MealAuthenticationException: $message${cause != null ? ' ($cause)' : ''}';
}

class MealAuthenticator {
  MealAuthenticator({
    this.baseUrl,
    this.username,
    this.password,
    this.account,
    Dio? httpClient,
    this.authPath = '/autenticar',
  }) : _httpClient = httpClient ?? Dio();

  final String? baseUrl;
  final String? username;
  final String? password;
  final String? account;
  final Dio _httpClient;
  final String authPath;

  Future<Map<String, String>> getToken() async {
    final resolvedBaseUrl =
        await _resolveValue(baseUrl, ConfigKeys.baseUrl, 'baseUrl');
    final resolvedUser =
        await _resolveValue(username, ConfigKeys.username, 'username');
    final resolvedPassword =
        await _resolveValue(password, ConfigKeys.password, 'password');
    final resolvedAccount =
        await _resolveValue(account, ConfigKeys.account, 'account');

    var storedToken = await ConfigKeys.token.read<String>();

    final isValid = storedToken != null
        ? await _validateStoredToken(
            storedToken,
            resolvedUser,
            resolvedAccount,
          )
        : false;

    if (!isValid) {
      storedToken = await _generateNewToken(
        baseUrl: resolvedBaseUrl,
        user: resolvedUser,
        password: resolvedPassword,
        account: resolvedAccount,
      );
    }

    return {'Authorization': 'Bearer $storedToken'};
  }

  Future<String> _resolveValue(
    String? provided,
    ConfigKeys key,
    String description,
  ) async {
    if (provided != null && provided.isNotEmpty) {
      await key.save(provided);
      return provided;
    }

    final stored = await key.read<String>();
    if (stored == null || stored.isEmpty) {
      throw MealAuthenticationException(
        'Missing $description configuration. '
        'Provide it in the constructor or persist it via ${key.name}.',
      );
    }

    return stored;
  }

  Future<bool> _validateStoredToken(
    String token,
    String user,
    String account,
  ) async {
    try {
      if (JwtDecoder.isExpired(token)) {
        await ConfigKeys.token.delete();
        return false;
      }

      final tokenData = JwtDecoder.decode(token);
      final tokenUser = tokenData['nameid']?.toString();
      final tokenAccount = tokenData['groupsid']?.toString();

      if (tokenUser != null && tokenUser != user) {
        await ConfigKeys.token.delete();
        return false;
      }

      if (tokenAccount != null && tokenAccount != account) {
        await _removeOldDatabase();
        await ConfigKeys.token.delete();
        return false;
      }

      return true;
    } catch (error) {
      await ConfigKeys.token.delete();
      return false;
    }
  }

  Future<String> _generateNewToken({
    required String baseUrl,
    required String user,
    required String password,
    required String account,
  }) async {
    final receiveTimeoutSeconds =
        await ConfigKeys.receiveTimeout.read<int>() ??
        NumberStandard.receiveTimeout.value;
    final sendTimeoutSeconds =
        await ConfigKeys.sendTimeout.read<int>() ??
        NumberStandard.sendTimeout.value;

    final uri = Uri.parse(baseUrl).resolve(authPath);

    try {
      final response = await _httpClient.postUri(
        uri,
        data: {
          'usuario': user,
          'senha': password,
          'conta': account,
        },
        options: Options(
          headers: {
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
          receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
          sendTimeout: Duration(seconds: sendTimeoutSeconds),
          responseType: ResponseType.json,
        ),
      );

      final token = _extractToken(response.data);
      await ConfigKeys.token.save(token);
      return token;
    } on DioException catch (error) {
      throw MealAuthenticationException('Failed to authenticate with API', error);
    } catch (error) {
      throw MealAuthenticationException('Invalid authentication response', error);
    }
  }

  String _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map && dataNode['accessToken'] is String) {
        return dataNode['accessToken'] as String;
      }
    }

    throw const MealAuthenticationException(
      'Authentication response did not contain a valid accessToken',
    );
  }

  Future<void> _removeOldDatabase() async {
    await DatabaseManager.databaseService.clearCache();
  }
}
