import 'package:intl/intl.dart';

class FlightModel {
  final int id;
  final String airline;
  final String flightNo;
  final int originId;
  final int destinationId;
  final String originCode;
  final String originName;
  final String originCity;
  final String destCode;
  final String destName;
  final String destCity;
  final DateTime departAt;
  final DateTime arriveAt;
  final double price;
  final int seatsAvailable;
  final int durationMinutes;

  FlightModel({
    required this.id,
    required this.airline,
    required this.flightNo,
    required this.originId,
    required this.destinationId,
    required this.originCode,
    required this.originName,
    required this.originCity,
    required this.destCode,
    required this.destName,
    required this.destCity,
    required this.departAt,
    required this.arriveAt,
    required this.price,
    required this.seatsAvailable,
    required this.durationMinutes,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      airline: json['airline'] ?? '',
      flightNo: json['flight_no'] ?? '',
      originId: json['origin_id'] is int ? json['origin_id'] : int.parse(json['origin_id'].toString()),
      destinationId: json['destination_id'] is int ? json['destination_id'] : int.parse(json['destination_id'].toString()),
      originCode: json['origin_code'] ?? '',
      originName: json['origin_name'] ?? '',
      originCity: json['origin_city'] ?? '',
      destCode: json['dest_code'] ?? '',
      destName: json['dest_name'] ?? '',
      destCity: json['dest_city'] ?? '',
      departAt: DateTime.parse(json['depart_at'].toString().replaceAll('Z', '')),
      arriveAt: DateTime.parse(json['arrive_at'].toString().replaceAll('Z', '')),
      price: double.parse(json['price'].toString()),
      seatsAvailable: json['seats_available'] is int ? json['seats_available'] : int.parse(json['seats_available'].toString()),
      durationMinutes: json['duration_minutes'] != null ? int.parse(json['duration_minutes'].toString()) : 90,
    );
  }

  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  String get departureTimeStr => DateFormat('HH:mm').format(departAt);
  String get arrivalTimeStr => DateFormat('HH:mm').format(arriveAt);
  String get dateStr => DateFormat('EEE, d MMM yyyy', 'id_ID').format(departAt);

  String get durationStr {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}j ${mins}m';
    if (hours > 0) return '${hours}j';
    return '${mins}m';
  }
}

class PassengerModel {
  String title; // Tn, Ny, Nn
  String fullName;
  String idNumber;

  PassengerModel({
    this.title = 'Tn',
    this.fullName = '',
    this.idNumber = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'full_name': fullName,
      'id_number': idNumber,
    };
  }

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      title: json['title'] ?? 'Tn',
      fullName: json['full_name'] ?? '',
      idNumber: json['id_number'] ?? '',
    );
  }
}
