import 'dart:convert';

class CacheModel {
  final DateTime creationDate;
  final dynamic value;

  CacheModel({
    required this.value,
    DateTime? creationDate,
  }) : creationDate = creationDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'creationDate': creationDate.millisecondsSinceEpoch,
      'value': value,
    };
  }

  factory CacheModel.fromMap(Map<String, dynamic> map) {
    return CacheModel(
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
      value: map['value'],
    );
  }

  factory CacheModel.fromJson(String source) =>
      CacheModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  CacheModel copyWith({
    DateTime? creationDate,
    dynamic value,
  }) {
    return CacheModel(
      creationDate: creationDate ?? this.creationDate,
      value: value ?? this.value,
    );
  }

  bool isExpired(Duration duration) {
    final now = DateTime.now();
    return now.difference(creationDate) > duration;
  }
}
