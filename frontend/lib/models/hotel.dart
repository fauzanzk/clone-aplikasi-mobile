import 'package:intl/intl.dart';

class RoomTypeModel {
  final int id;
  final int hotelId;
  final String name;
  final double pricePerNight;
  final int capacity;
  final int totalRooms;
  final int availableRooms;

  RoomTypeModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.pricePerNight,
    required this.capacity,
    required this.totalRooms,
    required this.availableRooms,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      hotelId: json['hotel_id'] is int ? json['hotel_id'] : int.parse(json['hotel_id'].toString()),
      name: json['name'] ?? '',
      pricePerNight: double.parse(json['price_per_night'].toString()),
      capacity: json['capacity'] is int ? json['capacity'] : int.parse(json['capacity'].toString()),
      totalRooms: json['total_rooms'] is int ? json['total_rooms'] : int.parse(json['total_rooms'].toString()),
      availableRooms: json['available_rooms'] != null
          ? (json['available_rooms'] is int ? json['available_rooms'] : int.parse(json['available_rooms'].toString()))
          : (json['total_rooms'] is int ? json['total_rooms'] : int.parse(json['total_rooms'].toString())),
    );
  }

  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(pricePerNight);
  }
}

class ReviewModel {
  final int id;
  final int rating;
  final String comment;
  final String userName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      rating: json['rating'] is int ? json['rating'] : int.parse(json['rating'].toString()),
      comment: json['comment'] ?? '',
      userName: json['user_name'] ?? 'Tamu TraveLokuy',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString().replaceAll('Z', '')) : DateTime.now(),
    );
  }

  String get timeAgo => DateFormat('d MMM yyyy', 'id_ID').format(createdAt);
}

class HotelModel {
  final int id;
  final String name;
  final int cityId;
  final String cityName;
  final String country;
  final String? address;
  final int star;
  final String? description;
  final List<String> facilities;
  final String imageUrl;
  final double rating;
  final double startPrice;
  final int totalReviews;
  bool isWishlist;
  final List<RoomTypeModel> rooms;
  final List<ReviewModel> reviews;

  HotelModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
    this.country = 'Indonesia',
    this.address,
    required this.star,
    this.description,
    required this.facilities,
    required this.imageUrl,
    required this.rating,
    required this.startPrice,
    this.totalReviews = 0,
    this.isWishlist = false,
    this.rooms = const [],
    this.reviews = const [],
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFacilities = [];
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        parsedFacilities = List<String>.from(json['facilities'].map((e) => e.toString()));
      }
    }

    List<RoomTypeModel> parsedRooms = [];
    if (json['rooms'] != null && json['rooms'] is List) {
      parsedRooms = (json['rooms'] as List).map((r) => RoomTypeModel.fromJson(r)).toList();
    }

    List<ReviewModel> parsedReviews = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      parsedReviews = (json['reviews'] as List).map((rev) => ReviewModel.fromJson(rev)).toList();
    }

    return HotelModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      cityId: json['city_id'] is int ? json['city_id'] : int.parse(json['city_id'].toString()),
      cityName: json['city_name'] ?? '',
      country: json['country'] ?? 'Indonesia',
      address: json['address'],
      star: json['star'] is int ? json['star'] : int.parse(json['star']?.toString() ?? '3'),
      description: json['description'],
      facilities: parsedFacilities,
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      rating: double.parse(json['rating']?.toString() ?? '4.5'),
      startPrice: double.parse(json['start_price']?.toString() ?? '500000'),
      totalReviews: json['total_reviews'] != null ? int.parse(json['total_reviews'].toString()) : parsedReviews.length,
      isWishlist: json['is_wishlist'] == true,
      rooms: parsedRooms,
      reviews: parsedReviews,
    );
  }

  String get formattedStartPrice {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(startPrice);
  }
}
