import 'package:intl/intl.dart';

class BusModel {
  final int id;
  final String operatorName;
  final String busClass;
  final String originCity;
  final String destCity;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final double rating;
  final int seatsAvailable;

  BusModel({
    required this.id,
    required this.operatorName,
    required this.busClass,
    required this.originCity,
    required this.destCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.rating,
    required this.seatsAvailable,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] as int,
      operatorName: json['operator_name'] as String,
      busClass: json['bus_class'] as String,
      originCity: json['origin_city'] as String,
      destCity: json['dest_city'] as String,
      departureTime: json['departure_time'] as String,
      arrivalTime: json['arrival_time'] as String,
      price: double.parse(json['price'].toString()),
      rating: double.tryParse(json['rating']?.toString() ?? '4.7') ?? 4.7,
      seatsAvailable: json['seats_available'] as int? ?? 20,
    );
  }

  String get formattedPrice {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return fmt.format(price);
  }
}

class AttractionModel {
  final int id;
  final String name;
  final String category;
  final int cityId;
  final String? cityName;
  final String location;
  final double rating;
  final double price;
  final String? imageUrl;
  final String? description;

  AttractionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.cityId,
    this.cityName,
    required this.location,
    required this.rating,
    required this.price,
    this.imageUrl,
    this.description,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    return AttractionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      cityId: json['city_id'] as int,
      cityName: json['city_name'] as String?,
      location: json['location'] as String,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  String get formattedPrice {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return fmt.format(price);
  }
}

class CarRentalModel {
  final int id;
  final String carName;
  final String transmission;
  final int capacity;
  final double pricePerDay;
  final String? imageUrl;
  final String providerName;

  CarRentalModel({
    required this.id,
    required this.carName,
    required this.transmission,
    required this.capacity,
    required this.pricePerDay,
    this.imageUrl,
    required this.providerName,
  });

  factory CarRentalModel.fromJson(Map<String, dynamic> json) {
    return CarRentalModel(
      id: json['id'] as int,
      carName: json['car_name'] as String,
      transmission: json['transmission'] as String,
      capacity: json['capacity'] as int,
      pricePerDay: double.parse(json['price_per_day'].toString()),
      imageUrl: json['image_url'] as String?,
      providerName: json['provider_name'] as String,
    );
  }

  String get formattedPrice {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return '${fmt.format(pricePerDay)} / hari';
  }
}

class InsuranceModel {
  final int id;
  final String planName;
  final String category;
  final double maxCoverage;
  final double price;
  final List<String> benefits;

  InsuranceModel({
    required this.id,
    required this.planName,
    required this.category,
    required this.maxCoverage,
    required this.price,
    required this.benefits,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedBenefits = [];
    if (json['benefits'] != null) {
      if (json['benefits'] is List) {
        parsedBenefits = (json['benefits'] as List).map((b) => b.toString()).toList();
      }
    }

    return InsuranceModel(
      id: json['id'] as int,
      planName: json['plan_name'] as String,
      category: json['category'] as String,
      maxCoverage: double.parse(json['max_coverage'].toString()),
      price: double.parse(json['price'].toString()),
      benefits: parsedBenefits,
    );
  }

  String get formattedPrice {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return fmt.format(price);
  }

  String get formattedCoverage {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return fmt.format(maxCoverage);
  }
}
