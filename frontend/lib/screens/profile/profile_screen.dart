import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../hotels/hotel_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn) {
        auth.fetchProfile();
        Provider.of<HotelProvider>(context, listen: false).fetchWishlist();
      }
    });
  }

  void _showEditProfileModal(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ubah Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Handphone'),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Simpan Perubahan',
                onPressed: () async {
                  final ok = await auth.updateProfile(nameController.text.trim(), phoneController.text.trim());
                  if (ok && mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui.')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final hotelProvider = Provider.of<HotelProvider>(context);
    final user = auth.user;
    final stats = auth.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.primary,
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditProfileModal(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: auth.isLoggedIn
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            user!.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                              ),
                              if (user.phone != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.phone!,
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text(
                          'Anda belum masuk ke akun TraveLokuy',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Masuk atau Daftar'),
                        ),
                      ],
                    ),
            ),

            if (auth.isLoggedIn && stats != null) ...[
              const SizedBox(height: 16),
              // Stats Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('Total Pesanan', '${stats['total_bookings'] ?? 0}', Icons.receipt_long),
                        Container(height: 36, width: 1, color: Colors.grey.shade200),
                        _buildStatCol('Aktif / Selesai', '${stats['active_bookings'] ?? 0}', Icons.check_circle_outline),
                        Container(height: 36, width: 1, color: Colors.grey.shade200),
                        _buildStatCol('Menunggu Bayar', '${stats['pending_bookings'] ?? 0}', Icons.timer_outlined),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Wishlist Hotel Section
            if (auth.isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hotel Favorit (Wishlist)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      '${hotelProvider.wishlist.length} Disimpan',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (hotelProvider.wishlist.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 32),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Belum ada hotel yang ditambahkan ke wishlist. Tekan ikon hati pada hotel untuk menyimpan.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: hotelProvider.wishlist.length,
                    itemBuilder: (context, i) {
                      final h = hotelProvider.wishlist[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: h.id)),
                          );
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(image: NetworkImage(h.imageUrl), fit: BoxFit.cover),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                                  h.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  h.cityName,
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],

            const SizedBox(height: 20),

            // App Settings & Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primary),
                      title: const Text('Bahasa'),
                      trailing: const Text('Bahasa Indonesia', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: AppColors.secondary),
                      title: const Text('Mata Uang'),
                      trailing: const Text('IDR (Rupiah)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppColors.primary),
                      title: const Text('Pusat Bantuan & FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.primary),
                      title: const Text('Tentang TraveLokuy App'),
                      trailing: const Text('v1.0.0 (MVP)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (auth.isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'Keluar dari Akun',
                  isOutlined: true,
                  backgroundColor: AppColors.danger,
                  textColor: AppColors.danger,
                  icon: Icons.logout,
                  onPressed: () {
                    auth.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anda telah keluar dari akun.')),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
