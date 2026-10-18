import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';
import 'e_ticket_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Semua', 'Menunggu Bayar', 'Selesai / Aktif', 'Batal / Expired'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterByTab(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _filterByTab(int index) {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    switch (index) {
      case 1:
        bp.fetchBookings(status: 'PENDING');
        break;
      case 2:
        bp.fetchBookings(status: 'PAID');
        break;
      case 3:
        bp.fetchBookings(status: 'CANCELLED');
        break;
      default:
        bp.fetchBookings(status: 'ALL');
    }
  }

  Future<void> _refresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      _filterByTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Masuk untuk Melihat Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Akses e-tiket pesawat dan voucher hotel Anda kapan saja dengan masuk ke akun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Masuk ke Akun'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: bookingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookingProvider.bookings.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Pesanan',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pesanan tiket pesawat dan hotel Anda akan muncul di halaman ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.bookings[index];
                      return _buildBookingCard(context, booking);
                    },
                  ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    Color statusBg;
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case 'PAID':
        statusBg = Colors.green.shade50;
        statusColor = AppColors.success;
        statusText = 'LUNAS (PAID)';
        break;
      case 'PENDING':
        statusBg = Colors.orange.shade50;
        statusColor = AppColors.pending;
        statusText = 'MENUNGGU BAYAR';
        break;
      case 'CANCELLED':
        statusBg = Colors.red.shade50;
        statusColor = AppColors.danger;
        statusText = 'DIBATALKAN';
        break;
      case 'EXPIRED':
        statusBg = Colors.grey.shade100;
        statusColor = Colors.grey.shade700;
        statusText = 'KEDALUWARSA';
        break;
      default:
        statusBg = Colors.grey.shade100;
        statusColor = Colors.grey;
        statusText = booking.status;
    }

    final isFlight = booking.type == 'FLIGHT';
    final isTrain = booking.type == 'TRAIN';

    IconData typeIcon = Icons.hotel;
    Color typeColor = AppColors.secondary;
    String typeLabel = 'Voucher Hotel';

    if (isFlight) {
      typeIcon = Icons.flight;
      typeColor = AppColors.primary;
      typeLabel = 'Tiket Pesawat';
    } else if (isTrain) {
      typeIcon = Icons.train_rounded;
      typeColor = const Color(0xFFED6B00);
      typeLabel = 'Tiket Kereta Api';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Type & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        typeIcon,
                        color: typeColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      typeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Booking Code & Content
            Text(
              'Kode Booking: ${booking.code}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            const SizedBox(height: 6),
            Text(
              isFlight
                  ? '${booking.airline ?? 'Pesawat'} (${booking.flightNo ?? '-'})'
                  : isTrain
                      ? '${booking.airline ?? 'Kereta Api'} (${booking.flightNo ?? 'KAI'})'
                      : (booking.hotelName ?? 'Hotel'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              (isFlight || isTrain)
                  ? '${booking.originCity ?? booking.originCode} ➔ ${booking.destCity ?? booking.destCode}'
                  : '${booking.roomName ?? 'Kamar'} • ${booking.hotelRooms ?? 1} Kamar',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),

            const Divider(height: 24),

            // Bottom Actions & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Biaya', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        booking.formattedTotalPrice,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    if (booking.isPending) ...[
                      OutlinedButton(
                        onPressed: () async {
                          final bp = Provider.of<BookingProvider>(context, listen: false);
                          final ok = await bp.cancelBooking(booking.id);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pesanan berhasil dibatalkan.')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Batal', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                bookingId: booking.id,
                                bookingCode: booking.code,
                                totalPrice: booking.totalPrice,
                                type: booking.type,
                                title: isFlight ? (booking.airline ?? 'Penerbangan') : (booking.hotelName ?? 'Hotel'),
                                subtitle: 'Kode Booking: ${booking.code}',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text('Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code, size: 16),
                        label: Text(booking.isPaid ? 'Lihat E-Tiket' : 'Detail Pesanan'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ETicketScreen(bookingId: booking.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
