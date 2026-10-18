import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/hotel_card.dart';
import 'hotel_detail_screen.dart';

class HotelResultsScreen extends StatelessWidget {
  const HotelResultsScreen({super.key});

  void _showSortModal(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final sortOptions = [
      {'key': 'rating_desc', 'label': 'Rating Tertinggi & Rekomendasi'},
      {'key': 'price_asc', 'label': 'Harga Terendah (Mulai Termurah)'},
      {'key': 'price_desc', 'label': 'Harga Tertinggi'},
      {'key': 'star_desc', 'label': 'Bintang Tertinggi (5 ke 1)'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Urutkan Hotel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = hotelProvider.sortBy == opt['key'];
                return RadioListTile<String>(
                  title: Text(opt['label']!, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  value: opt['key']!,
                  groupValue: hotelProvider.sortBy,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) hotelProvider.setSortBy(val);
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

  void _showStarModal(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final stars = [null, 5, 4, 3];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Bintang Hotel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...stars.map((s) {
                return RadioListTile<int?>(
                  title: Row(
                    children: [
                      Text(s == null ? 'Semua Bintang' : 'Bintang $s ke atas'),
                      const SizedBox(width: 8),
                      if (s != null)
                        Row(
                          children: List.generate(
                            s,
                            (index) => const Icon(Icons.star, color: AppColors.accentYellow, size: 16),
                          ),
                        ),
                    ],
                  ),
                  value: s,
                  groupValue: hotelProvider.selectedStar,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    hotelProvider.setStarFilter(val);
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
    final hotelProvider = Provider.of<HotelProvider>(context);
    final city = hotelProvider.selectedCity;
    final checkIn = hotelProvider.checkInDate;
    final checkOut = hotelProvider.checkOutDate;
    final nights = hotelProvider.nightsCount;
    final hotels = hotelProvider.hotels;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city?.name ?? 'Hotel Pilihan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              '${DateFormat('d MMM', 'id_ID').format(checkIn)} - ${DateFormat('d MMM', 'id_ID').format(checkOut)} ($nights Malam)',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Filter Chips Row
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

                // Star Filter Button
                InkWell(
                  onTap: () => _showStarModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hotelProvider.selectedStar != null ? AppColors.primary : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: hotelProvider.selectedStar != null ? Colors.blue.shade50 : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: hotelProvider.selectedStar != null ? AppColors.accentYellow : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hotelProvider.selectedStar != null ? 'Bintang ${hotelProvider.selectedStar}+' : 'Bintang',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hotelProvider.selectedStar != null ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                Text(
                  '${hotels.length} Hotel',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Hotel List
          Expanded(
            child: hotelProvider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Mencari hotel terbaik...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : hotels.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text('Hotel Tidak Ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                'Coba sesuaikan filter bintang atau tanggal menginap.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: hotels.length,
                        itemBuilder: (context, i) {
                          final hotel = hotels[i];
                          return HotelCard(
                            hotel: hotel,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HotelDetailScreen(hotelId: hotel.id),
                                ),
                              );
                            },
                            onToggleWishlist: () async {
                              final res = await hotelProvider.toggleWishlist(hotel.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res ? 'Disimpan ke wishlist!' : 'Dihapus dari wishlist.'),
                                  duration: const Duration(seconds: 1),
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
