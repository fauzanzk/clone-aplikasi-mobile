import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/airport.dart';
import '../models/flight.dart';
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/service_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? get token => _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      await setToken(data['data']['token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String? phone, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 && data['success'] == true) {
      await setToken(data['data']['token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final res = await http.get(url, headers: _headers());
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateProfile(String name, String? phone) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final res = await http.put(
      url,
      headers: _headers(),
      body: jsonEncode({'name': name, 'phone': phone}),
    );
    return jsonDecode(res.body);
  }

  // Airports & Cities
  Future<List<AirportModel>> getAirports({String? search}) async {
    var urlStr = '${ApiConstants.baseUrl}${ApiConstants.airports}';
    if (search != null && search.isNotEmpty) {
      urlStr += '?search=${Uri.encodeComponent(search)}';
    }
    final res = await http.get(Uri.parse(urlStr), headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((a) => AirportModel.fromJson(a)).toList();
    }
    return [];
  }

  Future<List<CityModel>> getCities({String? search}) async {
    var urlStr = '${ApiConstants.baseUrl}${ApiConstants.cities}';
    if (search != null && search.isNotEmpty) {
      urlStr += '?search=${Uri.encodeComponent(search)}';
    }
    final res = await http.get(Uri.parse(urlStr), headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((c) => CityModel.fromJson(c)).toList();
    }
    return [];
  }

  // Flights
  Future<List<FlightModel>> searchFlights({
    String? from,
    String? to,
    String? date,
    int pax = 1,
    String? airline,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{'pax': pax.toString()};
    if (from != null && from.isNotEmpty) queryParams['from'] = from;
    if (to != null && to.isNotEmpty) queryParams['to'] = to;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (airline != null && airline.isNotEmpty) queryParams['airline'] = airline;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flights}').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((f) => FlightModel.fromJson(f)).toList();
    }
    return [];
  }

  Future<FlightModel?> getFlightById(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flights}/$id');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] != null) {
      return FlightModel.fromJson(data['data']);
    }
    return null;
  }

  // Hotels
  Future<List<HotelModel>> searchHotels({
    String? city,
    String? checkin,
    String? checkout,
    int guests = 1,
    int? star,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{'guests': guests.toString()};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (checkin != null && checkin.isNotEmpty) queryParams['checkin'] = checkin;
    if (checkout != null && checkout.isNotEmpty) queryParams['checkout'] = checkout;
    if (star != null) queryParams['star'] = star.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hotels}').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((h) => HotelModel.fromJson(h)).toList();
    }
    return [];
  }

  Future<HotelModel?> getHotelById(int id, {String? checkin, String? checkout}) async {
    final queryParams = <String, String>{};
    if (checkin != null) queryParams['checkin'] = checkin;
    if (checkout != null) queryParams['checkout'] = checkout;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hotels}/$id').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] != null) {
      return HotelModel.fromJson(data['data']);
    }
    return null;
  }

  // Bookings
  Future<Map<String, dynamic>> createFlightBooking({
    required int flightId,
    required int seats,
    required List<PassengerModel> passengers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flightBooking}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'flight_id': flightId,
        'seats': seats,
        'passengers': passengers.map((p) => p.toJson()).toList(),
      }),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> createHotelBooking({
    required int roomTypeId,
    required String checkIn,
    required String checkOut,
    required int rooms,
    required int guests,
    required String guestName,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hotelBooking}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'room_type_id': roomTypeId,
        'check_in': checkIn,
        'check_out': checkOut,
        'rooms': rooms,
        'guests': guests,
        'guest_name': guestName,
      }),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> payBooking(int bookingId, String paymentMethod) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId/pay');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({'payment_method': paymentMethod}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId/cancel');
    final res = await http.post(url, headers: _headers());
    return jsonDecode(res.body);
  }

  Future<List<BookingModel>> getBookings({String? status}) async {
    var urlStr = '${ApiConstants.baseUrl}${ApiConstants.bookings}';
    if (status != null && status.isNotEmpty) {
      urlStr += '?status=$status';
    }
    final res = await http.get(Uri.parse(urlStr), headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((b) => BookingModel.fromJson(b)).toList();
    }
    return [];
  }

  Future<BookingModel?> getBookingDetail(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}/$id');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] != null) {
      return BookingModel.fromJson(data['data']);
    }
    return null;
  }

  // Wishlist & Reviews
  Future<List<HotelModel>> getWishlist() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wishlist}');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((h) => HotelModel.fromJson(h)).toList();
    }
    return [];
  }

  Future<bool> toggleWishlist(int hotelId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wishlist}/$hotelId');
    final res = await http.post(url, headers: _headers());
    final data = jsonDecode(res.body);
    return data['is_wishlist'] == true;
  }

  Future<bool> addReview(int hotelId, int rating, String comment) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.hotels}/$hotelId/reviews');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  // Stations & Trains
  Future<List<StationModel>> getStations({String? search}) async {
    var urlStr = '${ApiConstants.baseUrl}${ApiConstants.stations}';
    if (search != null && search.isNotEmpty) {
      urlStr += '?search=${Uri.encodeComponent(search)}';
    }
    final res = await http.get(Uri.parse(urlStr), headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((s) => StationModel.fromJson(s)).toList();
    }
    return [];
  }

  Future<List<TrainModel>> searchTrains({
    String? from,
    String? to,
    String? date,
    int pax = 1,
    String? trainClass,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{'pax': pax.toString()};
    if (from != null && from.isNotEmpty) queryParams['from'] = from;
    if (to != null && to.isNotEmpty) queryParams['to'] = to;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (trainClass != null && trainClass.isNotEmpty) queryParams['class'] = trainClass;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.trains}').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((t) => TrainModel.fromJson(t)).toList();
    }
    return [];
  }

  Future<TrainModel?> getTrainById(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.trains}/$id');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] != null) {
      return TrainModel.fromJson(data['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>> createTrainBooking({
    required int trainId,
    required int seats,
    required List<PassengerModel> passengers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.trainBooking}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'train_id': trainId,
        'seats': seats,
        'passengers': passengers.map((p) => p.toJson()).toList(),
      }),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> createBusBooking({
    required int busId,
    required int seatNo,
    String? passengerName,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.busBooking}');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'bus_id': busId,
        'seat_no': seatNo,
        if (passengerName != null) 'passenger_name': passengerName,
      }),
    );
    return jsonDecode(res.body);
  }

  // Other Services: Buses, Attractions, Cars, Insurances
  Future<List<BusModel>> getBuses({String? origin, String? dest}) async {
    final queryParams = <String, String>{};
    if (origin != null && origin.isNotEmpty) queryParams['origin'] = origin;
    if (dest != null && dest.isNotEmpty) queryParams['dest'] = dest;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.serviceBuses}').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((b) => BusModel.fromJson(b)).toList();
    }
    return [];
  }

  Future<List<AttractionModel>> getAttractions({int? cityId, String? category}) async {
    final queryParams = <String, String>{};
    if (cityId != null) queryParams['city_id'] = cityId.toString();
    if (category != null && category.isNotEmpty) queryParams['category'] = category;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.serviceAttractions}').replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((a) => AttractionModel.fromJson(a)).toList();
    }
    return [];
  }

  Future<List<CarRentalModel>> getCars() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.serviceCars}');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((c) => CarRentalModel.fromJson(c)).toList();
    }
    return [];
  }

  Future<List<InsuranceModel>> getInsurances() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.serviceInsurances}');
    final res = await http.get(url, headers: _headers());
    final data = jsonDecode(res.body);
    if (data['success'] == true && data['data'] is List) {
      return (data['data'] as List).map((i) => InsuranceModel.fromJson(i)).toList();
    }
    return [];
  }
}
