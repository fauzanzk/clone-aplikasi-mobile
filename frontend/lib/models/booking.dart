import 'package:intl/intl.dart';
import 'flight.dart';

class BookingModel {
  final int id;
  final String code;
  final String type; // 'FLIGHT' | 'HOTEL'
  final double totalPrice;
  String status; // 'PENDING' | 'PAID' | 'CANCELLED' | 'EXPIRED'
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  // Flight specific
  final String? airline;
  final String? flightNo;
  final DateTime? departAt;
  final DateTime? arriveAt;
  final String? originCode;
  final String? originCity;
  final String? destCode;
  final String? destCity;
  final int? flightSeats;
  final List<PassengerModel>? passengers;

  // Hotel specific
  final int? hotelId;
  final String? hotelName;
  final String? hotelImage;
  final int? hotelStar;
  final String? hotelAddress;
  final String? hotelCity;
  final String? roomName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? hotelRooms;
  final int? hotelGuests;
  final String? guestName;

  // Generic service specific (Xperience, Car Rental, Airport Transfer, Insurance)
  final String? itemName;
  final String? itemSubtitle;
  final dynamic serviceDetails;

  final String? qrData;

  BookingModel({
    required this.id,
    required this.code,
    required this.type,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    this.paidAt,
    this.expiresAt,
    required this.createdAt,
    this.airline,
    this.flightNo,
    this.departAt,
    this.arriveAt,
    this.originCode,
    this.originCity,
    this.destCode,
    this.destCity,
    this.flightSeats,
    this.passengers,
    this.hotelId,
    this.hotelName,
    this.hotelImage,
    this.hotelStar,
    this.hotelAddress,
    this.hotelCity,
    this.roomName,
    this.checkIn,
    this.checkOut,
    this.hotelRooms,
    this.hotelGuests,
    this.guestName,
    this.itemName,
    this.itemSubtitle,
    this.serviceDetails,
    this.qrData,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    List<PassengerModel>? parsedPassengers;
    if (json['passengers'] != null && json['passengers'] is List) {
      parsedPassengers = (json['passengers'] as List).map((p) => PassengerModel.fromJson(p)).toList();
    }

    return BookingModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      type: json['type'] ?? 'FLIGHT',
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['payment_method'],
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString().replaceAll('Z', '')) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString().replaceAll('Z', '')) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString().replaceAll('Z', '')) : DateTime.now(),
      airline: json['airline'],
      flightNo: json['flight_no'],
      departAt: json['depart_at'] != null ? DateTime.tryParse(json['depart_at'].toString().replaceAll('Z', '')) : null,
      arriveAt: json['arrive_at'] != null ? DateTime.tryParse(json['arrive_at'].toString().replaceAll('Z', '')) : null,
      originCode: json['origin_code'],
      originCity: json['origin_city'],
      destCode: json['dest_code'],
      destCity: json['dest_city'],
      flightSeats: json['flight_seats'] != null ? int.parse(json['flight_seats'].toString()) : null,
      passengers: parsedPassengers,
      hotelId: json['hotel_id'] != null ? int.parse(json['hotel_id'].toString()) : null,
      hotelName: json['hotel_name'],
      hotelImage: json['hotel_image'],
      hotelStar: json['hotel_star'] != null ? int.parse(json['hotel_star'].toString()) : null,
      hotelAddress: json['hotel_address'],
      hotelCity: json['hotel_city'],
      roomName: json['room_name'],
      checkIn: json['check_in'] != null ? DateTime.tryParse(json['check_in'].toString().split('T')[0]) : null,
      checkOut: json['check_out'] != null ? DateTime.tryParse(json['check_out'].toString().split('T')[0]) : null,
      hotelRooms: json['hotel_rooms'] != null ? int.parse(json['hotel_rooms'].toString()) : null,
      hotelGuests: json['hotel_guests'] != null ? int.parse(json['hotel_guests'].toString()) : null,
      guestName: json['guest_name'],
      itemName: json['item_name'],
      itemSubtitle: json['item_subtitle'],
      serviceDetails: json['service_details'],
      qrData: json['qr_data'] ?? json['code'],
    );
  }

  String get formattedTotalPrice {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(totalPrice);
  }

  String get formattedDate {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(createdAt);
  }

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isCancelled => status == 'CANCELLED';
  bool get isExpired => status == 'EXPIRED';

  int get nightsCount {
    if (checkIn != null && checkOut != null) {
      return checkOut!.difference(checkIn!).inDays;
    }
    return 1;
  }
}
