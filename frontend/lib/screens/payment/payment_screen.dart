import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_button.dart';
import '../orders/e_ticket_screen.dart';
import '../main_nav_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final String bookingCode;
  final double totalPrice;
  final String type; // 'FLIGHT' | 'HOTEL'
  final String title;
  final String subtitle;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.bookingCode,
    required this.totalPrice,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'BCA Virtual Account';
  late Timer _timer;
  int _secondsRemaining = 3599; // 59 mins 59 secs
  bool _isPaying = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'BCA Virtual Account',
      'category': 'Transfer Bank (Verifikasi Otomatis)',
      'icon': Icons.account_balance,
      'color': Colors.blue.shade800,
    },
    {
      'name': 'Mandiri Virtual Account',
      'category': 'Transfer Bank (Verifikasi Otomatis)',
      'icon': Icons.account_balance,
      'color': Colors.blue.shade600,
    },
    {
      'name': 'BRI Virtual Account',
      'category': 'Transfer Bank (Verifikasi Otomatis)',
      'icon': Icons.account_balance,
      'color': Colors.blue.shade900,
    },
    {
      'name': 'GoPay',
      'category': 'Uang Elektronik',
      'icon': Icons.account_balance_wallet,
      'color': Colors.cyan.shade700,
    },
    {
      'name': 'OVO',
      'category': 'Uang Elektronik',
      'icon': Icons.wallet,
      'color': Colors.purple.shade700,
    },
    {
      'name': 'Kartu Kredit / Debit Visa / Master',
      'category': 'Kartu Pembayaran',
      'icon': Icons.credit_card,
      'color': Colors.orange.shade800,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _countdownStr {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handlePayment() async {
    setState(() => _isPaying = true);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.payBooking(widget.bookingId, _selectedMethod);

    setState(() => _isPaying = false);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan dengan kode booking ${widget.bookingCode} telah lunas (PAID). E-tiket resmi Anda sudah siap!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Lihat E-Tiket / Voucher',
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ETicketScreen(bookingId: widget.bookingId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 1)),
                    (route) => false,
                  );
                },
                child: const Text('Buka Pesanan Saya'),
              ),
            ],
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran gagal atau batas waktu telah habis.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Simulasi'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Countdown Timer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.pending, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selesaikan Pembayaran Dalam',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          _countdownStr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pending,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      widget.bookingCode,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.type == 'FLIGHT' ? Icons.flight : Icons.hotel,
                          color: widget.type == 'FLIGHT' ? AppColors.primary : AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.type == 'FLIGHT' ? 'Tiket Pesawat' : 'Voucher Hotel',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Total yang Harus Dibayar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatCurrency.format(widget.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            // Payment Methods Selection List
            ..._methods.map((m) {
              final isSelected = _selectedMethod == m['name'];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m['icon'], color: m['color'], size: 24),
                  ),
                  title: Text(
                    m['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    m['category'],
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: Radio<String>(
                    value: m['name'],
                    groupValue: _selectedMethod,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMethod = val);
                    },
                  ),
                  onTap: () => setState(() => _selectedMethod = m['name']),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Pay CTA Button
            CustomButton(
              text: 'Bayar Sekarang (Simulasi)',
              icon: Icons.lock,
              isLoading: _isPaying,
              backgroundColor: AppColors.secondary,
              onPressed: _secondsRemaining > 0 ? _handlePayment : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Pembayaran aman • Simulasi langsung mengubah status ke PAID',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
