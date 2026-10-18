import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../services/api_service.dart';

class TrainProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<StationModel> _stations = [];
  StationModel? _originStation;
  StationModel? _destStation;
  DateTime _departureDate = DateTime.now();
  int _passengersCount = 1;

  List<TrainModel> _trains = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedClass; // null = all, or Eksekutif, Bisnis, Ekonomi, Kereta Cepat
  String _sortBy = 'price_asc';

  List<StationModel> get stations => _stations;
  StationModel? get originStation => _originStation;
  StationModel? get destStation => _destStation;
  DateTime get departureDate => _departureDate;
  int get passengersCount => _passengersCount;
  List<TrainModel> get trains => _trains;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedClass => _selectedClass;
  String get sortBy => _sortBy;

  Future<void> fetchStations() async {
    try {
      _stations = await _apiService.getStations();
      if (_stations.isNotEmpty) {
        // Defaults: Gambir (GMR) and Bandung (BD)
        _originStation = _stations.firstWhere(
          (s) => s.code == 'GMR',
          orElse: () => _stations[0],
        );
        _destStation = _stations.firstWhere(
          (s) => s.code == 'BD',
          orElse: () => _stations.length > 1 ? _stations[1] : _stations[0],
        );
      }
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  void setOriginStation(StationModel station) {
    _originStation = station;
    notifyListeners();
  }

  void setDestStation(StationModel station) {
    _destStation = station;
    notifyListeners();
  }

  void swapStations() {
    final temp = _originStation;
    _originStation = _destStation;
    _destStation = temp;
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

  void setClassFilter(String? trainClass) {
    _selectedClass = trainClass;
    searchTrains();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    searchTrains();
  }

  Future<void> searchTrains() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr =
          "${_departureDate.year}-${_departureDate.month.toString().padLeft(2, '0')}-${_departureDate.day.toString().padLeft(2, '0')}";

      _trains = await _apiService.searchTrains(
        from: _originStation?.code,
        to: _destStation?.code,
        date: dateStr,
        pax: _passengersCount,
        trainClass: _selectedClass,
        sortBy: _sortBy,
      );

      // If empty for exact date, search all available upcoming departures between origin and dest
      if (_trains.isEmpty) {
        _trains = await _apiService.searchTrains(
          from: _originStation?.code,
          to: _destStation?.code,
          pax: _passengersCount,
          trainClass: _selectedClass,
          sortBy: _sortBy,
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal kereta: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
