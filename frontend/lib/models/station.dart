class StationModel {
  final int id;
  final String code;
  final String name;
  final int cityId;
  final String cityName;
  final String country;
  final String type; // 'KAI' | 'WHOOSH'

  StationModel({
    required this.id,
    required this.code,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.country,
    required this.type,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      cityId: json['city_id'] as int,
      cityName: json['city_name'] as String? ?? 'Indonesia',
      country: json['country'] as String? ?? 'Indonesia',
      type: json['type'] as String? ?? 'KAI',
    );
  }

  bool get isWhoosh => type == 'WHOOSH';
}
