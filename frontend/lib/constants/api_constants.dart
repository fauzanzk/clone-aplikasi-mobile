import 'package:flutter/foundation.dart';

class ApiConstants {
  // Can be adjusted to Android emulator 10.0.2.2 if needed
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    // Default to localhost for desktop/web, 10.0.2.2 for Android emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/me';
  static const String airports = '/airports';
  static const String cities = '/cities';
  static const String flights = '/flights';
  static const String hotels = '/hotels';
  static const String stations = '/stations';
  static const String trains = '/trains';
  static const String flightBooking = '/bookings/flight';
  static const String hotelBooking = '/bookings/hotel';
  static const String trainBooking = '/bookings/train';
  static const String busBooking = '/bookings/bus';
  static const String serviceBooking = '/bookings/service';
  static const String serviceBuses = '/services/buses';
  static const String serviceAttractions = '/services/attractions';
  static const String serviceCars = '/services/cars';
  static const String serviceInsurances = '/services/insurances';
  static const String bookings = '/bookings';
  static const String wishlist = '/wishlist';
}
