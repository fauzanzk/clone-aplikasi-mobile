import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';

class AirportTransferScreen extends StatefulWidget {
  const AirportTransferScreen({super.key});

  @override
  State<AirportTransferScreen> createState() => _AirportTransferScreenState();
}

class _AirportTransferScreenState extends State<AirportTransferScreen> {
  String _selectedAirport = 'Bandara Soekarno-Hatta (CGK)';
  String _destinationAddress = 'Hotel Indonesia Kempinski, Jakarta Pusat';
  final TextEditingController _addressCtrl = TextEditingController(text: 'Hotel Indonesia Kempinski, Jakarta Pusat');

  final List<Map<String, dynamic>> _transferOptions = [
    {
      'name': 'Private Car Standard (Avanza/Xpander)',
      'provider': 'TraveLokuy Express Transfer',
      'capacity': '3-4 Penumpang + 3 Koper',
      'price': 185000,
      'duration': '45 - 60 mnt',
      'icon': Icons.directions_car,
      'badge': 'Terpopuler',
    },
    {
      'name': 'Premium Taxi (Bluebird & Silverbird)',
      'provider': 'Blue Bird Group',
      'capacity': '3-4 Penumpang + 2 Koper',
      'price': 240000,
      'duration': '40 - 55 mnt',
      'icon': Icons.local_taxi,
      'badge': 'Bebas Antre',
    },
    {
      'name': 'Airport Executive Van (Innova Reborn)',
      'provider': 'TraveLokuy Premier Fleet',
      'capacity': '5-6 Penumpang + 5 Koper',
      'price': 320000,
      'duration': '45 - 60 mnt',
      'icon': Icons.airport_shuttle,
      'badge': 'Keluarga & Grup',
    },
    {
      'name': 'DAMRI Airport Shuttle Bus',
      'provider': 'Perum DAMRI Bandara',
      'capacity': '1 Penumpang (Tiket Bus)',
      'price': 65000,
      'duration': '60 - 75 mnt',
      'icon': Icons.directions_bus,
      'badge': 'Paling Hemat',
    },
  ];

  void _showBookingConfirmation(Map<String, dynamic> option) {
    bool isBooking = false;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['name'],
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Disediakan oleh ${option['provider']}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.flight_land, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Titik Jemput (Kedatangan)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(_selectedAirport, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tujuan Pengantaran', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(_destinationAddress, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Tarif Lengkap', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            'Rp ${option['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isBooking
                            ? null
                            : () async {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                if (!authProvider.isLoggedIn) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Silakan login terlebih dahulu untuk memesan antar jemput bandara.'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                  return;
                                }

                                setSheetState(() => isBooking = true);
                                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                                final subtitle = '$_selectedAirport ➔ $_destinationAddress';
                                final res = await bookingProvider.createServiceBooking(
                                  serviceType: 'AIRPORT_TRANSFER',
                                  itemName: option['name'],
                                  itemSubtitle: subtitle,
                                  totalPrice: double.parse(option['price'].toString()),
                                  details: {
                                    'vehicle': option['name'],
                                    'provider': option['provider'],
                                    'pickup': _selectedAirport,
                                    'destination': _destinationAddress,
                                    'duration': option['duration'],
                                    'capacity': option['capacity'],
                                  },
                                );

                                if (!mounted) return;
                                setSheetState(() => isBooking = false);

                                if (res['success'] == true) {
                                  Navigator.pop(ctx);
                                  final bookingData = res['data'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentScreen(
                                        bookingId: bookingData['booking_id'],
                                        bookingCode: bookingData['code'],
                                        totalPrice: double.parse(bookingData['total_price'].toString()),
                                        type: 'AIRPORT_TRANSFER',
                                        title: option['name'],
                                        subtitle: subtitle,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] ?? 'Gagal membuat pesanan antar jemput bandara.'),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              },
                        child: isBooking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Konfirmasi & Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antar Jemput Bandara', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3F51B5),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Antar Jemput Nyaman dari & ke Bandara',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Harga pasti sudah termasuk tol, parkir, dan jaminan penjemputan tepat waktu.',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Airport selector dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedAirport,
                        items: const [
                          DropdownMenuItem(
                            value: 'Bandara Soekarno-Hatta (CGK)',
                            child: Text('Bandara Soekarno-Hatta (CGK)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Bandara Halim Perdanakusuma (HLP)',
                            child: Text('Bandara Halim Perdanakusuma (HLP)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Bandara Ngurah Rai Bali (DPS)',
                            child: Text('Bandara Ngurah Rai Bali (DPS)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Bandara Juanda Surabaya (SUB)',
                            child: Text('Bandara Juanda Surabaya (SUB)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Bandara YIA Yogyakarta (YIA)',
                            child: Text('Bandara YIA Yogyakarta (YIA)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAirport = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Destination address field
                  TextField(
                    controller: _addressCtrl,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Alamat tujuan (hotel / kantor / rumah)',
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF3F51B5)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) {
                      setState(() => _destinationAddress = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Kendaraan Penjemputan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ..._transferOptions.map((opt) {
                    final priceFmt = 'Rp ${opt['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
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
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8EAF6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(opt['icon'] as IconData, color: const Color(0xFF3F51B5), size: 22),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              opt['name'],
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              opt['provider'],
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EAF6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    opt['badge'],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF3F51B5)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(opt['capacity'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                const SizedBox(width: 14),
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(opt['duration'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Harga Bersih All-in', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(
                                      priceFmt,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.secondary),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3F51B5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  onPressed: () => _showBookingConfirmation(opt),
                                  child: const Text('Pesan Penjemputan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
