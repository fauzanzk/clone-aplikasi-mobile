import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'hotel_booking_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  HotelModel? _hotel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final detail = await hotelProvider.getHotelDetail(widget.hotelId);
    if (mounted) {
      setState(() {
        _hotel = detail;
        _isLoading = false;
      });
    }
  }

  void _showAddReviewModal() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tulis Ulasan Penginapan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text('Beri rating bintang:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= selectedRating ? Icons.star : Icons.star_border,
                          color: AppColors.accentYellow,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() => selectedRating = star);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ceritakan pengalaman Anda menginap di hotel ini...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Kirim Ulasan',
                    onPressed: () async {
                      if (commentController.text.trim().isEmpty) return;
                      final ok = await ApiService().addReview(
                        widget.hotelId,
                        selectedRating,
                        commentController.text.trim(),
                      );
                      if (ok && mounted) {
                        Navigator.pop(ctx);
                        _fetchDetail();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ulasan berhasil dikirim! Terima kasih.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hotel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Hotel')),
        body: const Center(child: Text('Hotel tidak ditemukan.')),
      );
    }

    final hotel = _hotel!;
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Image AppBar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hotel.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  hotel.isWishlist ? Icons.favorite : Icons.favorite_border,
                  color: hotel.isWishlist ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  final isWish = await hotelProvider.toggleWishlist(hotel.id);
                  setState(() => hotel.isWishlist = isWish);
                },
              ),
            ],
          ),

          // Hotel Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stars
                  Row(
                    children: List.generate(
                      hotel.star,
                      (index) => const Icon(Icons.star, color: AppColors.accentYellow, size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    hotel.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address ?? '${hotel.cityName}, ${hotel.country}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              hotel.rating.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Luar Biasa • ${hotel.reviews.length} ulasan terverifikasi',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Description
                  const Text('Tentang Hotel', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    hotel.description ?? 'Hotel nyaman dengan fasilitas lengkap dan pelayanan ramah berstandar bintang.',
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                  ),

                  const Divider(height: 32),

                  // Facilities
                  const Text('Fasilitas Utama', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel.facilities.map((f) {
                      return Chip(
                        label: Text(f, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        avatar: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
                        backgroundColor: Colors.blue.shade50,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),

                  const Divider(height: 32),

                  // Room Types
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tipe Kamar Tersedia', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      Text(
                        '${hotelProvider.nightsCount} Malam',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...hotel.rooms.map((room) {
                    final isAvailable = room.availableRooms > 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    room.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Sisa ${room.availableRooms} Kamar' : 'Habis Terjual',
                                    style: TextStyle(
                                      color: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Maksimal ${room.capacity} Tamu',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.wifi, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                const Text('WiFi Gratis', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Harga per malam', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      Text(
                                        room.formattedPrice,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.secondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: isAvailable
                                      ? () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => HotelBookingScreen(hotel: hotel, room: room),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  child: const Text('Pilih Kamar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const Divider(height: 32),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ulasan Tamu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      TextButton.icon(
                        icon: const Icon(Icons.rate_review, size: 16),
                        label: const Text('Tulis Ulasan'),
                        onPressed: _showAddReviewModal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (hotel.reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada ulasan untuk hotel ini. Jadilah yang pertama!', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...hotel.reviews.map((rev) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Row(
                                    children: List.generate(
                                      rev.rating,
                                      (index) => const Icon(Icons.star, color: AppColors.accentYellow, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(rev.comment, style: const TextStyle(fontSize: 13, height: 1.4)),
                              const SizedBox(height: 4),
                              Text(rev.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
