import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../models/flight.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  final FlightModel flight;
  final int passengersCount;

  const FlightBookingScreen({
    super.key,
    required this.flight,
    required this.passengersCount,
  });

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
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
          content: Text('Mohon lengkapi semua data penumpang.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final res = await bookingProvider.createFlightBooking(
      flightId: widget.flight.id,
      seats: widget.passengersCount,
      passengers: _passengers,
    );

    if (res['success'] == true && mounted) {
      final bookingData = res['data'];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingId: bookingData['booking_id'],
            bookingCode: bookingData['code'],
            totalPrice: double.parse(bookingData['total_price'].toString()),
            type: 'FLIGHT',
            title: '${widget.flight.airline} (${widget.flight.flightNo})',
            subtitle: '${widget.flight.originCode} ➔ ${widget.flight.destCode} • ${widget.passengersCount} Kursi',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal membuat pesanan penerbangan.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final total = flight.price * widget.passengersCount;
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail & Data Penumpang'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Summary Card
              Card(
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
                                const Icon(Icons.flight, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${flight.airline} • ${flight.flightNo}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Konfirmasi Instan',
                              style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(flight.departureTimeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              Text(flight.originCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          const Expanded(
                            child: Center(
                              child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(flight.arrivalTimeStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              Text(flight.destCode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        flight.dateStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Data Penumpang', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Pastikan nama sesuai dengan identitas resmi (KTP/Paspor) untuk keperluan check-in.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Passengers Form List
              ...List.generate(widget.passengersCount, (index) {
                final p = _passengers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Penumpang ${index + 1} (Dewasa)',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title selection
                        Row(
                          children: ['Tn', 'Ny', 'Nn'].map((t) {
                            final isSel = p.title == t;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(t),
                                selected: isSel,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (sel) {
                                  if (sel) setState(() => p.title = t);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Full name
                        TextFormField(
                          initialValue: p.fullName,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            hintText: 'Misal: Budi Santoso',
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Nama penumpang wajib diisi' : null,
                          onChanged: (val) => p.fullName = val,
                        ),
                        const SizedBox(height: 12),

                        // ID / KTP Number
                        TextFormField(
                          initialValue: p.idNumber,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'No. KTP / Paspor',
                            hintText: '16 digit NIK',
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Nomor identitas wajib diisi' : null,
                          onChanged: (val) => p.idNumber = val,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Price Summary Card
              Card(
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
                          Expanded(
                            child: Text(
                              'Tarif Dasar (${widget.passengersCount}x)',
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
                              'Pajak & Biaya Layanan',
                              style: TextStyle(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Gratis (Termasuk)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
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

              // Proceed CTA
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
