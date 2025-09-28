enum DatabaseBoxes {
  cache('cache_box'),
  config('config_box');

  const DatabaseBoxes(this.name);
  final String name;
}

enum CacheKeys {
  userData('user_data'),
  apiResponse('api_response'),
  settings('settings'),
  tempData('temp_data');

  const CacheKeys(this.key);
  final String key;
}

enum ConfigKeys {
  token('token'),
  baseUrl('base_url'),
  userId('user_id'),
  lastSync('last_sync'),
  preferences('preferences');

  const ConfigKeys(this.key);
  final String key;
}
