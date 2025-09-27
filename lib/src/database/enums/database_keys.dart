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
  username('username'),
  password('password'),
  account('account'),
  lastSync('last_sync'),
  preferences('preferences'),
  defaultKeySelector('default_key_selector'),
  receiveTimeout('receive_timeout'),
  sendTimeout('send_timeout'),
  retryOptions('retry_options');

  const ConfigKeys(this.key);
  final String key;
}

enum NumberStandard {
  receiveTimeout(5),
  sendTimeout(5),
  retryOptions(5);

  const NumberStandard(this.value);
  final int value;
}
