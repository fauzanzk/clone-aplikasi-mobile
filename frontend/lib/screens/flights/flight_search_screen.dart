import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/airport.dart';
import '../../providers/flight_provider.dart';
import '../../widgets/custom_button.dart';
import 'flight_results_screen.dart';

class FlightSearchScreen extends StatelessWidget {
  const FlightSearchScreen({super.key});

  void _showAirportPicker(BuildContext context, bool isOrigin) {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    final airports = flightProvider.airports;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = airports.where((a) {
              final q = searchQuery.toLowerCase();
              return a.name.toLowerCase().contains(q) ||
                  a.code.toLowerCase().contains(q) ||
                  a.cityName.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isOrigin ? 'Pilih Kota / Bandara Asal' : 'Pilih Kota / Bandara Tujuan',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kota atau bandara (misal: CGK, Bali, Surabaya)...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final a = filtered[i];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flight, color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            '${a.cityName} (${a.code})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(a.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          onTap: () {
                            if (isOrigin) {
                              flightProvider.setOriginAirport(a);
                            } else {
                              flightProvider.setDestAirport(a);
                            }
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPassengerPicker(BuildContext context) {
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int pax = flightProvider.passengersCount;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Penumpang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dewasa / Anak', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Usia 2 tahun ke atas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: pax > 1 ? () => setState(() => pax--) : null,
                          ),
                          Text(
                            pax.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: pax < 7 ? () => setState(() => pax++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Selesai',
                    onPressed: () {
                      flightProvider.setPassengersCount(pax);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cari Tiket Pesawat'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Wave / Gradient Container
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Origin & Destination Row with Swap Button
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Column(
                            children: [
                              // Origin
                              InkWell(
                                onTap: () => _showAirportPicker(context, true),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flight_takeoff, color: AppColors.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Dari',
                                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                            Text(
                                              origin != null
                                                  ? '${origin.cityName} (${origin.code})'
                                                  : 'Pilih Kota Asal',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (origin != null)
                                              Text(
                                                origin.name,
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 44),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 24),

                              // Destination
                              InkWell(
                                onTap: () => _showAirportPicker(context, false),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flight_land, color: AppColors.secondary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ke',
                                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                            Text(
                                              dest != null
                                                  ? '${dest.cityName} (${dest.code})'
                                                  : 'Pilih Kota Tujuan',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (dest != null)
                                              Text(
                                                dest.name,
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 44),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Swap Button
                          Positioned(
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                                onPressed: () => flightProvider.swapAirports(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Date & Pax Row
                      Row(
                        children: [
                          // Date Picker
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  flightProvider.setDepartureDate(picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tanggal Pergi',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          DateFormat('d MMM yyyy', 'id_ID').format(date),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(height: 36, width: 1, color: Colors.grey.shade200),
                          ),

                          // Passenger Picker
                          Expanded(
                            child: InkWell(
                              onTap: () => _showPassengerPicker(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Penumpang',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$pax Penumpang',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Search CTA Button
                      CustomButton(
                        text: 'Cari Tiket Pesawat',
                        icon: Icons.search,
                        onPressed: () {
                          flightProvider.searchFlights();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FlightResultsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tips Info Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Booking Tiket Pesawat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    icon: Icons.price_check,
                    title: 'Harga Jujur Tanpa Biaya Tersembunyi',
                    desc: 'Harga yang ditampilkan sudah termasuk pajak bandara dan biaya bahan bakar.',
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Jaminan Tiket Resmi',
                    desc: 'Tiket diterbitkan langsung oleh maskapai resmi rekanan TraveLokuy.',
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    icon: Icons.qr_code_2,
                    title: 'E-Tiket Instan dengan QR Code',
                    desc: 'Langsung terima kode booking dan e-tiket setelah pembayaran simulasi.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
