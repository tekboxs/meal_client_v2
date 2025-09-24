class ConfigModel {
  final String key;
  final dynamic value;
  final DateTime? lastUpdated;

  ConfigModel({
    required this.key,
    required this.value,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      key: map['key'] as String,
      value: map['value'],
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int)
          : null,
    );
  }

  ConfigModel copyWith({
    String? key,
    dynamic value,
    DateTime? lastUpdated,
  }) {
    return ConfigModel(
      key: key ?? this.key,
      value: value ?? this.value,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
