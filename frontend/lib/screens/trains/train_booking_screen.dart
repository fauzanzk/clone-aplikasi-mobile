import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/flight.dart'; // Uses PassengerModel
import '../../models/train.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';

class TrainBookingScreen extends StatefulWidget {
  final TrainModel train;
  final int passengersCount;

  const TrainBookingScreen({
    super.key,
    required this.train,
    required this.passengersCount,
  });

  @override
  State<TrainBookingScreen> createState() => _TrainBookingScreenState();
}

class _TrainBookingScreenState extends State<TrainBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<PassengerModel> _passengers;

  @override
  void initState() {
    super.initState();
    final authUser = Provider.of<AuthProvider>(context, listen: false).user;
    _passengers = List.generate(
      widget.passengersCount,
      (i) => PassengerModel(
        title: 'Tn',
        fullName: i == 0 && authUser != null ? authUser.name : '',
        idNumber: i == 0 ? '3171012345670001' : '',
      ),
    );
  }

  Future<void> _handleProceed() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true) return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data penumpang (Nama & NIK).'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final res = await bookingProvider.createTrainBooking(
      trainId: widget.train.id,
      seats: widget.passengersCount,
      passengers: _passengers,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      final bookingData = res['data'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingId: bookingData['booking_id'],
            bookingCode: bookingData['code'],
            totalPrice: double.parse(bookingData['total_price'].toString()),
            type: 'TRAIN',
            title: '${widget.train.trainName} (${widget.train.trainNo})',
            subtitle: '${widget.train.originCode} ➔ ${widget.train.destCode} • ${widget.passengersCount} Kursi',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal membuat pesanan tiket kereta.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final isWhoosh = widget.train.isWhoosh;
    final badgeColor = isWhoosh ? const Color(0xFFC00A27) : const Color(0xFFED6B00);
    final totalPrice = widget.train.price * widget.passengersCount;
    final totalFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pemesanan Tiket Kereta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Train Summary Card
              Card(
                elevation: 1,
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
                            child: Row(
                              children: [
                                Icon(
                                  isWhoosh ? Icons.speed_rounded : Icons.train_rounded,
                                  color: badgeColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.train.trainName} (${widget.train.trainNo})',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.train.classType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.train.departAt),
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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
                                Text(
                                  widget.train.departureTimeStr,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.train.originName} (${widget.train.originCode})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.train.originCity,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Text(
                                  widget.train.durationStr,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.train.arrivalTimeStr,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.train.destName} (${widget.train.destCode})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                Text(
                                  widget.train.destCity,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
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

              // Contact Info Card
              const Text('Data Pemesan (Kontak)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_pin, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.isLoggedIn ? (authProvider.user?.name ?? 'Pengguna') : 'Belum Masuk',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.isLoggedIn ? (authProvider.user?.email ?? '') : 'Silakan login saat melanjutkan pemesanan',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Passengers Forms
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data Penumpang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(
                    '${widget.passengersCount} Orang',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...List.generate(widget.passengersCount, (index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penumpang ${index + 1} (Dewasa)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: DropdownButtonFormField<String>(
                                value: _passengers[index].title,
                                decoration: const InputDecoration(labelText: 'Titel'),
                                items: const [
                                  DropdownMenuItem(value: 'Tn', child: Text('Tn.')),
                                  DropdownMenuItem(value: 'Ny', child: Text('Ny.')),
                                  DropdownMenuItem(value: 'Nn', child: Text('Nn.')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _passengers[index].title = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: _passengers[index].fullName,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap (sesuai KTP)',
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Wajib diisi';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _passengers[index].fullName = val?.trim() ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _passengers[index].idNumber,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Identitas (NIK KTP / Paspor)',
                            hintText: '16 digit NIK',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 6) {
                              return 'Nomor identitas minimal 6 karakter';
                            }
                            return null;
                          },
                          onSaved: (val) => _passengers[index].idNumber = val?.trim() ?? '',
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Price Summary
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rincian Harga', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tiket Kereta (${widget.passengersCount}x)'),
                          Text(totalFmt, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Biaya Layanan'),
                          Text('GRATIS', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(
                            totalFmt,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: isWhoosh ? badgeColor : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Lanjut ke Pembayaran',
                isLoading: bookingProvider.isLoading,
                onPressed: _handleProceed,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
