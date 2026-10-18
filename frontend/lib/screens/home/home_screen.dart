import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/train_provider.dart';
import '../../widgets/banner_slider.dart';
import '../flights/flight_search_screen.dart';
import '../hotels/hotel_search_screen.dart';
import '../trains/train_search_screen.dart';
import '../services/bus_search_screen.dart';
import '../services/xperience_screen.dart';
import '../services/car_rental_screen.dart';
import '../services/airport_transfer_screen.dart';
import '../services/insurance_screen.dart';
import '../notifications/notification_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with TraveLoka Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TraveLokuy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0194F3), Color(0xFF0064D2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              // Notification Bell Icon with Badge
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5E1F), // Orange/Red badge
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                tooltip: 'Notifikasi',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              if (user == null)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login, color: Colors.white, size: 16),
                  label: const Text(
                    'Masuk',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Body
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting card
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Text(
                          user != null ? user.name[0].toUpperCase() : 'G',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? 'Halo, ${user.name}!' : 'Halo, Traveler!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user != null
                                  ? 'Mau liburan ke mana hari ini?'
                                  : 'Masuk akun untuk melihat pesanan dan diskon',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Unified Services Card (8 Services in 4x2 Grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 6, bottom: 16),
                            child: Text(
                              'Layanan TraveLokuy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Row 1: Pesawat, Hotel, Kereta Api, Bus & Travel
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildServiceItem(
                                context: context,
                                title: 'Tiket Pesawat',
                                icon: Icons.flight_takeoff_rounded,
                                color: AppColors.primary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
                                ),
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Hotel & Resort',
                                icon: Icons.hotel_rounded,
                                color: AppColors.secondary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HotelSearchScreen()),
                                ),
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Kereta Api',
                                icon: Icons.train_rounded,
                                color: const Color(0xFFED6B00),
                                badge: 'WHOOSH',
                                onTap: () {
                                  TrainProvider? existing;
                                  try {
                                    existing = Provider.of<TrainProvider>(context, listen: false);
                                  } catch (_) {}

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => existing != null
                                          ? ChangeNotifierProvider.value(
                                              value: existing,
                                              child: const TrainSearchScreen(),
                                            )
                                          : ChangeNotifierProvider(
                                              create: (_) => TrainProvider(),
                                              child: const TrainSearchScreen(),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Bus & Travel',
                                icon: Icons.directions_bus_rounded,
                                color: const Color(0xFF1E824C),
                                badge: 'HEMAT',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const BusSearchScreen()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Row 2: Xperience, Rental Mobil, Antar Bandara, Asuransi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildServiceItem(
                                context: context,
                                title: 'Xperience',
                                icon: Icons.attractions_rounded,
                                color: const Color(0xFFE91E63),
                                badge: 'DISKON',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const XperienceScreen()),
                                ),
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Rental Mobil',
                                icon: Icons.directions_car_rounded,
                                color: const Color(0xFF0097A7),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CarRentalScreen()),
                                ),
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Antar Bandara',
                                icon: Icons.airport_shuttle_rounded,
                                color: const Color(0xFF3F51B5),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AirportTransferScreen()),
                                ),
                              ),
                              _buildServiceItem(
                                context: context,
                                title: 'Asuransi',
                                icon: Icons.health_and_safety_rounded,
                                color: const Color(0xFF00897B),
                                badge: 'OJK',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const InsuranceScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Promo Banners Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Promo Menarik Hari Ini',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const BannerSlider(),

                const SizedBox(height: 24),

                // Popular Destinations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'Destinasi Populer di Indonesia',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDestinationCard(
                        context,
                        title: 'Bali',
                        image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=400&q=80',
                        cityName: 'Bali (Denpasar)',
                      ),
                      _buildDestinationCard(
                        context,
                        title: 'Yogyakarta',
                        image: 'https://images.unsplash.com/photo-1584810359583-96fc3448beaa?auto=format&fit=crop&w=400&q=80',
                        cityName: 'Yogyakarta',
                      ),
                      _buildDestinationCard(
                        context,
                        title: 'Jakarta',
                        image: 'https://images.unsplash.com/photo-1555899434-94d1368aa7af?auto=format&fit=crop&w=400&q=80',
                        cityName: 'Jakarta',
                      ),
                      _buildDestinationCard(
                        context,
                        title: 'Surabaya',
                        image: 'https://images.unsplash.com/photo-1570789210967-2cac24afeb00?auto=format&fit=crop&w=400&q=80',
                        cityName: 'Surabaya',
                      ),
                      _buildDestinationCard(
                        context,
                        title: 'Bandung',
                        image: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=400&q=80',
                        cityName: 'Bandung',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context, {
    required String title,
    required String image,
    required String cityName,
  }) {
    return GestureDetector(
      onTap: () {
        final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
        final city = hotelProvider.cities.firstWhere(
          (c) => c.name.toLowerCase().contains(cityName.toLowerCase()),
          orElse: () => hotelProvider.cities.isNotEmpty ? hotelProvider.cities[0] : null!,
        );
        if (city != null) {
          hotelProvider.setSelectedCity(city);
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HotelSearchScreen()),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Cari Hotel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    if (badge != null)
                      Positioned(
                        top: -3,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: badge == 'WHOOSH'
                                ? const Color(0xFFC00A27)
                                : (badge == 'DISKON' ? const Color(0xFFE91E63) : const Color(0xFFED6B00)),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
