import 'package:intl/intl.dart';

class TrainModel {
  final int id;
  final String trainName;
  final String trainNo;
  final String classType;
  final int originId;
  final String originCode;
  final String originName;
  final String originType;
  final String originCity;
  final int destId;
  final String destCode;
  final String destName;
  final String destType;
  final String destCity;
  final DateTime departAt;
  final DateTime arriveAt;
  final double price;
  final int seatsAvailable;
  final int durationMinutes;

  TrainModel({
    required this.id,
    required this.trainName,
    required this.trainNo,
    required this.classType,
    required this.originId,
    required this.originCode,
    required this.originName,
    required this.originType,
    required this.originCity,
    required this.destId,
    required this.destCode,
    required this.destName,
    required this.destType,
    required this.destCity,
    required this.departAt,
    required this.arriveAt,
    required this.price,
    required this.seatsAvailable,
    required this.durationMinutes,
  });

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    return TrainModel(
      id: json['id'] as int,
      trainName: json['train_name'] as String,
      trainNo: json['train_no'] as String,
      classType: json['class_type'] as String,
      originId: json['origin_id'] as int,
      originCode: json['origin_code'] as String,
      originName: json['origin_name'] as String,
      originType: json['origin_type'] as String? ?? 'KAI',
      originCity: json['origin_city'] as String,
      destId: json['dest_id'] as int,
      destCode: json['dest_code'] as String,
      destName: json['dest_name'] as String,
      destType: json['dest_type'] as String? ?? 'KAI',
      destCity: json['dest_city'] as String,
      departAt: DateTime.parse(json['depart_at']),
      arriveAt: DateTime.parse(json['arrive_at']),
      price: double.parse(json['price'].toString()),
      seatsAvailable: json['seats_available'] as int,
      durationMinutes: json['duration_minutes'] != null
          ? int.parse(json['duration_minutes'].toString())
          : 60,
    );
  }

  bool get isWhoosh =>
      trainName.toLowerCase().contains('whoosh') || classType.toLowerCase().contains('cepat');

  String get formattedPrice {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return fmt.format(price);
  }

  String get departureTimeStr => DateFormat('HH:mm').format(departAt);
  String get arrivalTimeStr => DateFormat('HH:mm').format(arriveAt);
  String get dateStr => DateFormat('EEE, d MMM yyyy', 'id_ID').format(departAt);

  String get durationStr {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}j';
    return '${hours}j ${mins}m';
  }
}
