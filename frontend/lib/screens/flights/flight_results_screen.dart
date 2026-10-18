import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/flight_provider.dart';
import '../../widgets/flight_card.dart';
import 'flight_booking_screen.dart';

class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  void _showFilterModal(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    final airlines = ['Semua Maskapai', 'Garuda Indonesia', 'Batik Air', 'Citilink', 'Lion Air', 'Super Air Jet'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String? currentAirline = flightProvider.selectedAirline;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Maskapai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...airlines.map((a) {
                final isSelected = (a == 'Semua Maskapai' && currentAirline == null) || (a == currentAirline);
                return RadioListTile<String?>(
                  title: Text(a, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  value: a == 'Semua Maskapai' ? null : a,
                  groupValue: currentAirline,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    flightProvider.setAirlineFilter(val);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    final sortOptions = [
      {'key': 'price_asc', 'label': 'Harga Terendah (Termurah)'},
      {'key': 'price_desc', 'label': 'Harga Tertinggi'},
      {'key': 'time_asc', 'label': 'Waktu Berangkat Paling Awal'},
      {'key': 'time_desc', 'label': 'Waktu Berangkat Paling Akhir'},
      {'key': 'duration_asc', 'label': 'Durasi Penerbangan Tercepat'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Urutkan Hasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = flightProvider.sortBy == opt['key'];
                return RadioListTile<String>(
                  title: Text(opt['label']!, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  value: opt['key']!,
                  groupValue: flightProvider.sortBy,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      flightProvider.setSortBy(val);
                    }
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context);
    final origin = flightProvider.originAirport;
    final dest = flightProvider.destAirport;
    final date = flightProvider.departureDate;
    final pax = flightProvider.passengersCount;
    final flights = flightProvider.flights;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${origin?.code ?? 'CGK'} ➔ ${dest?.code ?? 'DPS'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              '${DateFormat('d MMM yyyy', 'id_ID').format(date)} • $pax Penumpang',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Filter & Sort Sticky Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                // Urutkan Button
                InkWell(
                  onTap: () => _showSortModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.sort, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Urutkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter Maskapai Button
                InkWell(
                  onTap: () => _showFilterModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: flightProvider.selectedAirline != null ? AppColors.primary : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: flightProvider.selectedAirline != null ? Colors.blue.shade50 : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: flightProvider.selectedAirline != null ? AppColors.primary : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          flightProvider.selectedAirline ?? 'Maskapai',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: flightProvider.selectedAirline != null ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                Text(
                  '${flights.length} Penerbangan',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Flight Cards List
          Expanded(
            child: flightProvider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Mencari penerbangan terbaik...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : flights.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flight_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'Penerbangan Tidak Ditemukan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Coba ubah tanggal keberangkatan atau filter maskapai.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: flights.length,
                        itemBuilder: (context, i) {
                          final flight = flights[i];
                          return FlightCard(
                            flight: flight,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlightBookingScreen(flight: flight, passengersCount: pax),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
