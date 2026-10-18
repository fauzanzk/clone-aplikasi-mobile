import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/custom_button.dart';
import 'hotel_results_screen.dart';

class HotelSearchScreen extends StatelessWidget {
  const HotelSearchScreen({super.key});

  void _showCityPicker(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final cities = hotelProvider.cities;

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
            final filtered = cities.where((c) {
              return c.name.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pilih Kota atau Destinasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kota (misal: Bali, Jakarta, Jogja)...',
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
                        final c = filtered[i];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.location_city, color: AppColors.secondary, size: 20),
                          ),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(c.country, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          onTap: () {
                            hotelProvider.setSelectedCity(c);
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

  void _showGuestRoomPicker(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int guests = hotelProvider.guestsCount;
        int rooms = hotelProvider.roomsCount;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jumlah Tamu & Kamar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  // Rooms
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kamar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: rooms > 1 ? () => setState(() => rooms--) : null,
                          ),
                          Text('$rooms', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: rooms < 5 ? () => setState(() => rooms++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Guests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tamu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: guests > 1 ? () => setState(() => guests--) : null,
                          ),
                          Text('$guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: guests < 10 ? () => setState(() => guests++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Terapkan',
                    onPressed: () {
                      hotelProvider.setGuestsAndRooms(guests, rooms);
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
    final hotelProvider = Provider.of<HotelProvider>(context);
    final city = hotelProvider.selectedCity;
    final checkIn = hotelProvider.checkInDate;
    final checkOut = hotelProvider.checkOutDate;
    final nights = hotelProvider.nightsCount;
    final guests = hotelProvider.guestsCount;
    final rooms = hotelProvider.roomsCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cari Hotel & Penginapan'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0075DE)],
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
                      // City Picker
                      InkWell(
                        onTap: () => _showCityPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.location_on, color: AppColors.secondary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Kota atau Destinasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text(
                                      city != null ? city.name : 'Pilih Kota Tujuan',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 24),

                      // Checkin / Checkout Date Range Picker
                      InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                            initialDateRange: DateTimeRange(start: checkIn, end: checkOut),
                          );
                          if (range != null) {
                            hotelProvider.setDates(range.start, range.end);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_month, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check-in: ${DateFormat('d MMM yyyy', 'id_ID').format(checkIn)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Check-out: ${DateFormat('d MMM yyyy', 'id_ID').format(checkOut)} ($nights Malam)',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 24),

                      // Guests & Rooms
                      InkWell(
                        onTap: () => _showGuestRoomPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.people, color: Colors.purple.shade700, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tamu & Kamar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text(
                                      '$guests Tamu, $rooms Kamar',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Search CTA
                      CustomButton(
                        text: 'Cari Hotel Pilihan',
                        icon: Icons.search,
                        backgroundColor: AppColors.secondary,
                        onPressed: () {
                          hotelProvider.searchHotels();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HotelResultsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Benefit banners
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keuntungan Pesan Hotel di TraveLokuy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _buildBenefitCard(
                    icon: Icons.money_off,
                    title: 'Bisa Bayar Nanti & Simulasi Mudah',
                    desc: 'Dapatkan batas waktu bayar hingga 1 jam sebelum pesanan kedaluwarsa.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitCard(
                    icon: Icons.star_border,
                    title: 'Ulasan Terverifikasi',
                    desc: 'Hanya tamu asli yang telah menginap yang dapat menulis ulasan & rating hotel.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitCard(
                    icon: Icons.favorite_border,
                    title: 'Simpan ke Wishlist',
                    desc: 'Pantau harga dan tandai penginapan impian Anda untuk liburan nanti.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.secondary, size: 20),
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
