import 'package:hive/hive.dart';
import 'database_container.dart';
import 'database_service.dart';

class DatabaseManager {
  static bool _isInitialized = false;

  static Future<void> initialize({String? path}) async {
    if (_isInitialized) return;

    Hive.init(path);
    DatabaseContainer.registerServices();
    await DatabaseContainer.initAllServices();
    
    _isInitialized = true;
  }

  static Future<void> dispose() async {
    if (!_isInitialized) return;

    await DatabaseContainer.closeAllServices();
    DatabaseContainer.reset();
    
    _isInitialized = false;
  }

  static DatabaseService get databaseService => DatabaseContainer.databaseService;

  static bool get isInitialized => _isInitialized;
}
