import 'package:flutter/material.dart';
import '../models/airport.dart';
import '../models/flight.dart';
import '../services/api_service.dart';

class FlightProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AirportModel> _airports = [];
  AirportModel? _originAirport;
  AirportModel? _destAirport;
  DateTime _departureDate = DateTime.now();
  int _passengersCount = 1;

  List<FlightModel> _flights = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedAirline;
  String _sortBy = 'price_asc';

  List<AirportModel> get airports => _airports;
  AirportModel? get originAirport => _originAirport;
  AirportModel? get destAirport => _destAirport;
  DateTime get departureDate => _departureDate;
  int get passengersCount => _passengersCount;
  List<FlightModel> get flights => _flights;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedAirline => _selectedAirline;
  String get sortBy => _sortBy;

  Future<void> fetchAirports() async {
    try {
      _airports = await _apiService.getAirports();
      if (_airports.isNotEmpty) {
        // Defaults: CGK (Soekarno-Hatta) & DPS (Bali)
        _originAirport = _airports.firstWhere(
          (a) => a.code == 'CGK',
          orElse: () => _airports[0],
        );
        _destAirport = _airports.firstWhere(
          (a) => a.code == 'DPS',
          orElse: () => _airports.length > 1 ? _airports[1] : _airports[0],
        );
      }
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  void setOriginAirport(AirportModel airport) {
    _originAirport = airport;
    notifyListeners();
  }

  void setDestAirport(AirportModel airport) {
    _destAirport = airport;
    notifyListeners();
  }

  void swapAirports() {
    final temp = _originAirport;
    _originAirport = _destAirport;
    _destAirport = temp;
    notifyListeners();
  }

  void setDepartureDate(DateTime date) {
    _departureDate = date;
    notifyListeners();
  }

  void setPassengersCount(int count) {
    _passengersCount = count;
    notifyListeners();
  }

  void setAirlineFilter(String? airline) {
    _selectedAirline = airline;
    searchFlights();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    searchFlights();
  }

  Future<void> searchFlights() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = "${_departureDate.year}-${_departureDate.month.toString().padLeft(2, '0')}-${_departureDate.day.toString().padLeft(2, '0')}";
      _flights = await _apiService.searchFlights(
        from: _originAirport?.code,
        to: _destAirport?.code,
        date: dateStr,
        pax: _passengersCount,
        airline: _selectedAirline,
        sortBy: _sortBy,
      );

      // If empty on chosen date, search all upcoming flights between these airports
      if (_flights.isEmpty) {
        _flights = await _apiService.searchFlights(
          from: _originAirport?.code,
          to: _destAirport?.code,
          pax: _passengersCount,
          airline: _selectedAirline,
          sortBy: _sortBy,
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat penerbangan: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
