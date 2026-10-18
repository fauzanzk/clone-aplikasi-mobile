import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'ALL';

  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'E-Tiket Whoosh Siap Digunakan!',
        message: 'Tiket Whoosh Kereta Cepat G1242 Halim ➔ Tegalluar Anda sudah terbit. Gate boarding stasiun ditutup 5 menit sebelum jam berangkat.',
        time: '15 menit lalu',
        category: 'TRANSACTION',
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFFC00A27),
        iconBg: const Color(0xFFFFECEF),
        isRead: false,
        deepLink: 'ORDER',
      ),
      NotificationModel(
        id: '2',
        title: 'EPIC SALE TraveLokuy 2026 Aktif!',
        message: 'Diskon kilat s/d 70% untuk tiket pesawat Garuda, Batik Air & Hotel Bintang 5 di Bali & Jogja. Kupon berlaku s/d pukul 23:59 WIB.',
        time: '2 jam lalu',
        category: 'PROMO',
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFF5E1F),
        iconBg: const Color(0xFFFFF3E8),
        isRead: false,
        deepLink: 'PROMO',
      ),
      NotificationModel(
        id: '3',
        title: 'Pembayaran Tiket Pesawat Berhasil',
        message: 'Transaksi pemesanan tiket penerbangan GA-401 Jakarta (CGK) ➔ Bali (DPS) senilai Rp 2.500.000 telah lunas diverifikasi.',
        time: '5 jam lalu',
        category: 'TRANSACTION',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF05A660),
        iconBg: const Color(0xFFE8F5E9),
        isRead: false,
        deepLink: 'ORDER',
      ),
      NotificationModel(
        id: '4',
        title: 'Voucher Diskon Xperience 25%',
        message: 'Klaim diskon spesial tiket wahana Dufan Ancol, Taman Safari, dan Waterbom Bali telah ditambahkan ke akun Anda.',
        time: '1 hari lalu',
        category: 'PROMO',
        icon: Icons.attractions_rounded,
        iconColor: const Color(0xFFE91E63),
        iconBg: const Color(0xFFFCE4EC),
        isRead: true,
        deepLink: 'XPERIENCE',
      ),
      NotificationModel(
        id: '5',
        title: 'Armada Sleeper Bus Baru',
        message: 'Kini tersedia armada bus sleeper mewah Rosalia Indah & DAMRI Royal Class di menu Bus & Travel TraveLokuy!',
        time: '2 hari lalu',
        category: 'INFO',
        icon: Icons.directions_bus_rounded,
        iconColor: const Color(0xFF1E824C),
        iconBg: const Color(0xFFE8F5E9),
        isRead: true,
        deepLink: 'BUS',
      ),
      NotificationModel(
        id: '6',
        title: 'Perlindungan TraveLokuy Safe Aktif',
        message: 'Polis asuransi perjalanan Anda terverifikasi aktif terdaftar OJK dengan jaminan kompensasi s/d Rp 100.000.000.',
        time: '3 hari lalu',
        category: 'INFO',
        icon: Icons.health_and_safety_rounded,
        iconColor: const Color(0xFF00897B),
        iconBg: const Color(0xFFE0F2F1),
        isRead: true,
        deepLink: 'INSURANCE',
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai sudah dibaca.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notif) {
    setState(() {
      notif.isRead = true;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notif.icon, color: notif.iconColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notif.time,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              Text(
                notif.message,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedCategory == 'ALL') return true;
      return n.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 22),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('ALL', 'Semua'),
                  const SizedBox(width: 8),
                  _buildTabChip('TRANSACTION', 'Pesanan & Transaksi'),
                  const SizedBox(width: 8),
                  _buildTabChip('PROMO', 'Promo & Diskon'),
                  const SizedBox(width: 8),
                  _buildTabChip('INFO', 'Info Perjalanan'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // List Notifications
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak Ada Notifikasi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Semua info pemesanan dan promo Anda akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      return InkWell(
                        onTap: () => _showNotificationDetail(item),
                        child: Container(
                          color: item.isRead ? Colors.transparent : Colors.blue.shade50.withOpacity(0.35),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.iconBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item.icon, color: item.iconColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.time,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: item.isRead ? Colors.grey.shade600 : Colors.black87,
                                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) {
        setState(() => _selectedCategory = category);
      },
    );
  }
}
