class AirportModel {
  final int id;
  final String code;
  final String name;
  final int cityId;
  final String cityName;
  final String country;

  AirportModel({
    required this.id,
    required this.code,
    required this.name,
    required this.cityId,
    required this.cityName,
    required this.country,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      cityId: json['city_id'] is int ? json['city_id'] : int.parse(json['city_id'].toString()),
      cityName: json['city_name'] ?? '',
      country: json['country'] ?? 'Indonesia',
    );
  }

  String get displayName => '$cityName ($code) - $name';
}

class CityModel {
  final int id;
  final String name;
  final String country;

  CityModel({
    required this.id,
    required this.name,
    required this.country,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      country: json['country'] ?? 'Indonesia',
    );
  }
}
