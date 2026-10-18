import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traveloka_app/models/station.dart';
import 'package:traveloka_app/models/train.dart';
import 'package:traveloka_app/models/service_models.dart';
import 'package:traveloka_app/models/booking.dart';
import 'package:traveloka_app/widgets/train_card.dart';
import 'package:traveloka_app/screens/notifications/notification_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  test('TraveLokuyApp sanity check', () {
    expect(1 + 1, 2);
  });

  test('StationModel deserializes properly', () {
    final json = {
      'id': 1,
      'code': 'GMR',
      'name': 'Stasiun Gambir',
      'city_id': 1,
      'city_name': 'Jakarta',
      'country': 'Indonesia',
      'type': 'KAI',
    };
    final s = StationModel.fromJson(json);
    expect(s.code, 'GMR');
    expect(s.isWhoosh, false);

    final whooshJson = {
      'id': 3,
      'code': 'HLM',
      'name': 'Stasiun Kereta Cepat Halim',
      'city_id': 1,
      'city_name': 'Jakarta',
      'country': 'Indonesia',
      'type': 'WHOOSH',
    };
    final w = StationModel.fromJson(whooshJson);
    expect(w.isWhoosh, true);
  });

  test('TrainModel formats duration and price properly', () {
    final json = {
      'id': 1,
      'train_name': 'Whoosh KCIC G1001',
      'train_no': 'G1001',
      'class_type': 'Kereta Cepat',
      'origin_id': 3,
      'origin_code': 'HLM',
      'origin_name': 'Stasiun Kereta Cepat Halim',
      'origin_type': 'WHOOSH',
      'origin_city': 'Jakarta',
      'dest_id': 5,
      'dest_code': 'TGL',
      'dest_name': 'Stasiun Tegalluar',
      'dest_type': 'WHOOSH',
      'dest_city': 'Bandung',
      'depart_at': '2026-10-18T07:00:00.000Z',
      'arrive_at': '2026-10-18T07:45:00.000Z',
      'price': 250000,
      'seats_available': 40,
      'duration_minutes': 45,
    };
    final t = TrainModel.fromJson(json);
    expect(t.isWhoosh, true);
    expect(t.durationStr, '45m');
    expect(t.formattedPrice, contains('250.000'));
  });

  test('Service models deserialize correctly', () {
    final busJson = {
      'id': 1,
      'operator_name': 'Rosalia Indah',
      'bus_class': 'Executive Plus',
      'origin_city': 'Jakarta',
      'dest_city': 'Yogyakarta',
      'departure_time': '18:00',
      'arrival_time': '04:00',
      'price': 240000,
      'rating': 4.8,
      'seats_available': 18,
    };
    final bus = BusModel.fromJson(busJson);
    expect(bus.operatorName, 'Rosalia Indah');

    final carJson = {
      'id': 1,
      'car_name': 'Toyota Avanza',
      'transmission': 'Manual',
      'capacity': 7,
      'price_per_day': 350000,
      'provider_name': 'Mitra Rent',
    };
    final car = CarRentalModel.fromJson(carJson);
    expect(car.capacity, 7);

    final insJson = {
      'id': 1,
      'plan_name': 'Travel Safe Basic',
      'category': 'Domestik',
      'max_coverage': 100000000,
      'price': 25000,
      'benefits': ['Kecelakaan diri', 'Pembatalan perjalanan'],
    };
    final ins = InsuranceModel.fromJson(insJson);
    expect(ins.benefits.length, 2);
  });

  testWidgets('TrainCard renders without crashing', (tester) async {
    final train = TrainModel(
      id: 1,
      trainName: 'Whoosh KCIC',
      trainNo: 'G1234',
      classType: 'Kereta Cepat',
      originId: 1,
      originCode: 'HLM',
      originName: 'Halim',
      originType: 'WHOOSH',
      originCity: 'Jakarta',
      destId: 2,
      destCode: 'TGL',
      destName: 'Tegalluar',
      destType: 'WHOOSH',
      destCity: 'Bandung',
      departAt: DateTime(2026, 10, 18, 8, 0),
      arriveAt: DateTime(2026, 10, 18, 8, 45),
      price: 250000,
      seatsAvailable: 15,
      durationMinutes: 45,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrainCard(
            train: train,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Whoosh KCIC'), findsOneWidget);
    expect(find.text('WHOOSH'), findsOneWidget);
  });

  testWidgets('NotificationScreen renders tabs and notifications', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationScreen(),
      ),
    );

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pesanan & Transaksi'), findsOneWidget);
    expect(find.text('Promo & Diskon'), findsOneWidget);
    expect(find.text('E-Tiket Whoosh Siap Digunakan!'), findsOneWidget);
  });

  test('BookingModel handles service booking types properly', () {
    final xperienceJson = {
      'id': 10,
      'code': 'TLB3UWJXF',
      'type': 'XPERIENCE',
      'total_price': 500000,
      'status': 'PAID',
      'payment_method': 'BCA Virtual Account',
      'item_name': 'Dufan Ancol Theme Park',
      'item_subtitle': 'Taman Hiburan • Jakarta Utara • 2 Tiket',
      'service_details': {'ticket_count': 2},
      'created_at': '2026-10-18T15:54:27.000Z',
    };

    final b = BookingModel.fromJson(xperienceJson);
    expect(b.id, 10);
    expect(b.type, 'XPERIENCE');
    expect(b.itemName, 'Dufan Ancol Theme Park');
    expect(b.itemSubtitle, 'Taman Hiburan • Jakarta Utara • 2 Tiket');
    expect(b.isPaid, true);
    expect(b.formattedTotalPrice, 'Rp 500.000');
  });
}

