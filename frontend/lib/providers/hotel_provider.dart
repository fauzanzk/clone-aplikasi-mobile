import 'package:flutter/material.dart';
import '../models/airport.dart';
import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _guestsCount = 2;
  int _roomsCount = 1;

  List<HotelModel> _hotels = [];
  List<HotelModel> _wishlist = [];
  bool _isLoading = false;
  String? _errorMessage;

  int? _selectedStar;
  String _sortBy = 'rating_desc';

  List<CityModel> get cities => _cities;
  CityModel? get selectedCity => _selectedCity;
  DateTime get checkInDate => _checkInDate;
  DateTime get checkOutDate => _checkOutDate;
  int get guestsCount => _guestsCount;
  int get roomsCount => _roomsCount;
  List<HotelModel> get hotels => _hotels;
  List<HotelModel> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedStar => _selectedStar;
  String get sortBy => _sortBy;

  int get nightsCount {
    final diff = _checkOutDate.difference(_checkInDate).inDays;
    return diff > 0 ? diff : 1;
  }

  Future<void> fetchCities() async {
    try {
      _cities = await _apiService.getCities();
      if (_cities.isNotEmpty) {
        // Default to Bali or first
        _selectedCity = _cities.firstWhere(
          (c) => c.name.toLowerCase().contains('bali'),
          orElse: () => _cities[0],
        );
      }
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  void setSelectedCity(CityModel city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setDates(DateTime checkIn, DateTime checkOut) {
    _checkInDate = checkIn;
    _checkOutDate = checkOut;
    notifyListeners();
  }

  void setGuestsAndRooms(int guests, int rooms) {
    _guestsCount = guests;
    _roomsCount = rooms;
    notifyListeners();
  }

  void setStarFilter(int? star) {
    _selectedStar = star;
    searchHotels();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    searchHotels();
  }

  Future<void> searchHotels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final checkInStr = "${_checkInDate.year}-${_checkInDate.month.toString().padLeft(2, '0')}-${_checkInDate.day.toString().padLeft(2, '0')}";
      final checkOutStr = "${_checkOutDate.year}-${_checkOutDate.month.toString().padLeft(2, '0')}-${_checkOutDate.day.toString().padLeft(2, '0')}";

      _hotels = await _apiService.searchHotels(
        city: _selectedCity?.name,
        checkin: checkInStr,
        checkout: checkOutStr,
        guests: _guestsCount,
        star: _selectedStar,
        sortBy: _sortBy,
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat hotel: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<HotelModel?> getHotelDetail(int id) async {
    try {
      final checkInStr = "${_checkInDate.year}-${_checkInDate.month.toString().padLeft(2, '0')}-${_checkInDate.day.toString().padLeft(2, '0')}";
      final checkOutStr = "${_checkOutDate.year}-${_checkOutDate.month.toString().padLeft(2, '0')}-${_checkOutDate.day.toString().padLeft(2, '0')}";
      return await _apiService.getHotelById(id, checkin: checkInStr, checkout: checkOutStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchWishlist() async {
    try {
      _wishlist = await _apiService.getWishlist();
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  Future<bool> toggleWishlist(int hotelId) async {
    try {
      final isNowWishlist = await _apiService.toggleWishlist(hotelId);
      // Update local hotel list
      for (final h in _hotels) {
        if (h.id == hotelId) {
          h.isWishlist = isNowWishlist;
        }
      }
      await fetchWishlist();
      notifyListeners();
      return isNowWishlist;
    } catch (e) {
      return false;
    }
  }
}
