import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/flight.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentStatusFilter = 'ALL';

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentStatusFilter => _currentStatusFilter;

  Future<void> fetchBookings({String status = 'ALL'}) async {
    _isLoading = true;
    _currentStatusFilter = status;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _apiService.getBookings(status: status == 'ALL' ? null : status);
    } catch (e) {
      _errorMessage = 'Gagal mengambil pesanan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BookingModel?> fetchBookingDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentBooking = await _apiService.getBookingDetail(id);
      _isLoading = false;
      notifyListeners();
      return _currentBooking;
    } catch (e) {
      _errorMessage = 'Gagal mengambil detail pesanan.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<Map<String, dynamic>> createFlightBooking({
    required int flightId,
    required int seats,
    required List<PassengerModel> passengers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createFlightBooking(
        flightId: flightId,
        seats: seats,
        passengers: passengers,
      );
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createHotelBooking({
    required int roomTypeId,
    required String checkIn,
    required String checkOut,
    required int rooms,
    required int guests,
    required String guestName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createHotelBooking(
        roomTypeId: roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
        guests: guests,
        guestName: guestName,
      );
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createTrainBooking({
    required int trainId,
    required int seats,
    required List<PassengerModel> passengers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createTrainBooking(
        trainId: trainId,
        seats: seats,
        passengers: passengers,
      );
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createBusBooking({
    required int busId,
    required int seatNo,
    String? passengerName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createBusBooking(
        busId: busId,
        seatNo: seatNo,
        passengerName: passengerName,
      );
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createServiceBooking({
    required String serviceType,
    required String itemName,
    String? itemSubtitle,
    required double totalPrice,
    dynamic details,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.createServiceBooking(
        serviceType: serviceType,
        itemName: itemName,
        itemSubtitle: itemSubtitle,
        totalPrice: totalPrice,
        details: details,
      );
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> payBooking(int bookingId, String paymentMethod) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.payBooking(bookingId, paymentMethod);
      if (res['success'] == true) {
        await fetchBookings(status: _currentStatusFilter);
        await fetchBookingDetail(bookingId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Ignored
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> cancelBooking(int bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.cancelBooking(bookingId);
      if (res['success'] == true) {
        await fetchBookings(status: _currentStatusFilter);
        await fetchBookingDetail(bookingId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Ignored
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
