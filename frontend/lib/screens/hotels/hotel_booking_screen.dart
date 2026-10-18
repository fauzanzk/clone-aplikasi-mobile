import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';

class HotelBookingScreen extends StatefulWidget {
  final HotelModel hotel;
  final RoomTypeModel room;

  const HotelBookingScreen({
    super.key,
    required this.hotel,
    required this.room,
  });

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _guestNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final authUser = Provider.of<AuthProvider>(context, listen: false).user;
    _guestNameController = TextEditingController(text: authUser?.name ?? 'Budi Santoso');
    _emailController = TextEditingController(text: authUser?.email ?? 'budi@travelokuy.com');
    _phoneController = TextEditingController(text: authUser?.phone ?? '081234567890');
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleProceed() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true) return;
    }

    if (!_formKey.currentState!.validate()) return;

    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    final checkInStr = "${hotelProvider.checkInDate.year}-${hotelProvider.checkInDate.month.toString().padLeft(2, '0')}-${hotelProvider.checkInDate.day.toString().padLeft(2, '0')}";
    final checkOutStr = "${hotelProvider.checkOutDate.year}-${hotelProvider.checkOutDate.month.toString().padLeft(2, '0')}-${hotelProvider.checkOutDate.day.toString().padLeft(2, '0')}";

    final res = await bookingProvider.createHotelBooking(
      roomTypeId: widget.room.id,
      checkIn: checkInStr,
      checkOut: checkOutStr,
      rooms: hotelProvider.roomsCount,
      guests: hotelProvider.guestsCount,
      guestName: _guestNameController.text.trim(),
    );

    if (res['success'] == true && mounted) {
      final bookingData = res['data'];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingId: bookingData['booking_id'],
            bookingCode: bookingData['code'],
            totalPrice: double.parse(bookingData['total_price'].toString()),
            type: 'HOTEL',
            title: widget.hotel.name,
            subtitle: '${widget.room.name} • ${hotelProvider.nightsCount} Malam (${hotelProvider.roomsCount} Kamar)',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal membuat pesanan hotel.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final nights = hotelProvider.nightsCount;
    final rooms = hotelProvider.roomsCount;
    final total = widget.room.pricePerNight * nights * rooms;
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan Hotel'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Card Summary
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.hotel.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey.shade200),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.hotel.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.room.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.hotel.cityName,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Check-in', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text(
                                  DateFormat('EEE, d MMM yyyy', 'id_ID').format(hotelProvider.checkInDate),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$nights Malam',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Check-out', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text(
                                  DateFormat('EEE, d MMM yyyy', 'id_ID').format(hotelProvider.checkOutDate),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Data Tamu Utama', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _guestNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Tamu',
                          hintText: 'Sesuai KTP / Paspor',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nama tamu wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Konfirmasi Voucher',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.email, color: AppColors.primary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Handphone',
                          hintText: '081234567890',
                          prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Price Summary
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rincian Harga Menginap', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Tarif Kamar ($nights malam x $rooms kamar)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(formatCurrency.format(total)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Pajak & Biaya Kebersihan',
                              style: TextStyle(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Termasuk', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Total Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatCurrency.format(total),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Consumer<BookingProvider>(
                builder: (context, bp, _) {
                  return CustomButton(
                    text: 'Lanjutkan ke Pembayaran',
                    isLoading: bp.isLoading,
                    onPressed: _handleProceed,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
