import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../constants/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';

class ETicketScreen extends StatefulWidget {
  final int bookingId;

  const ETicketScreen({super.key, required this.bookingId});

  @override
  State<ETicketScreen> createState() => _ETicketScreenState();
}

class _ETicketScreenState extends State<ETicketScreen> {
  BookingModel? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final detail = await bp.fetchBookingDetail(widget.bookingId);
    if (mounted) {
      setState(() {
        _booking = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('E-Tiket')),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }

    final booking = _booking!;
    final isFlight = booking.type == 'FLIGHT';
    final isTrain = booking.type == 'TRAIN';
    final isBus = booking.type == 'BUS';

    String screenTitle = 'Voucher Hotel Resmi';
    Color headerBg = AppColors.secondary;
    IconData headerIcon = Icons.hotel;
    Color screenBg = const Color(0xFF0064D2);

    if (isFlight) {
      screenTitle = 'E-Tiket Penerbangan Resmi';
      headerBg = AppColors.primary;
      headerIcon = Icons.flight_takeoff;
      screenBg = const Color(0xFF0064D2);
    } else if (isTrain) {
      screenTitle = 'E-Tiket Kereta Api Resmi';
      headerBg = const Color(0xFFED6B00);
      headerIcon = Icons.train_rounded;
      screenBg = const Color(0xFFC85A00);
    } else if (isBus) {
      screenTitle = 'E-Tiket Bus & Shuttle Resmi';
      headerBg = const Color(0xFF1E824C);
      headerIcon = Icons.directions_bus_rounded;
      screenBg = const Color(0xFF145A32);
    }

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: screenBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ticket Card Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Header in Ticket
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: headerBg,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(headerIcon, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'TraveLokuy',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Booking Code Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'KODE BOOKING / PNR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: booking.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kode booking disalin!')),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                booking.code,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.copy, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notch Cutout / Dashed Divider
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 28,
                        decoration: BoxDecoration(
                          color: screenBg,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dashCount = (constraints.constrainWidth() / 10).floor();
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                dashCount,
                                (_) => const SizedBox(
                                  width: 5,
                                  height: 1.5,
                                  child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 28,
                        decoration: BoxDecoration(
                          color: screenBg,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                        ),
                      ),
                    ],
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: (isFlight || isTrain || isBus) ? _buildFlightDetails(booking) : _buildHotelDetails(booking),
                  ),

                  // QR Code Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: QrImageView(
                            data: booking.qrData ?? booking.code,
                            version: QrVersions.auto,
                            size: 150.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.textPrimary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pindai QR ini saat Check-in Bandara / Resepsionis Hotel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Share & Download Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Simpan PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('E-Tiket berhasil diunduh ke memori perangkat.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tautan E-Tiket disalin ke papan klip.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetails(BookingModel booking) {
    final isTrain = booking.type == 'TRAIN';
    final operatorLabel = isTrain ? 'Kereta Api' : 'Maskapai';
    final codeLabel = isTrain ? 'No. Kereta' : 'No. Penerbangan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Airline & Flight Number
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(operatorLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  booking.airline ?? (isTrain ? 'Kereta Api' : 'Garuda Indonesia'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(codeLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  booking.flightNo ?? (isTrain ? 'KA-01' : 'GA-401'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Route & Hours
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.originCode ?? (isTrain ? 'GMR' : 'CGK'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isTrain ? const Color(0xFFED6B00) : AppColors.primary,
                  ),
                ),
                Text(
                  booking.originCity ?? 'Jakarta',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (booking.departAt != null)
                  Text(
                    DateFormat('HH:mm').format(booking.departAt!),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            Icon(
              isTrain ? Icons.train_rounded : Icons.flight_takeoff,
              color: isTrain ? const Color(0xFFED6B00) : AppColors.primary,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  booking.destCode ?? (isTrain ? 'BD' : 'DPS'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.secondary),
                ),
                Text(
                  booking.destCity ?? (isTrain ? 'Bandung' : 'Bali'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (booking.arriveAt != null)
                  Text(
                    DateFormat('HH:mm').format(booking.arriveAt!),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Passenger List
        const Text('Daftar Penumpang:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        if (booking.passengers != null && booking.passengers!.isNotEmpty)
          ...booking.passengers!.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('${p.title}. ${p.fullName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    if (p.idNumber.isNotEmpty)
                      Text(' (${p.idNumber})', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ))
        else
          const Text('1 Penumpang Terdaftar', style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildHotelDetails(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.hotelName ?? 'Hotel TraveLokuy',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 4),
        Text(
          booking.hotelAddress ?? booking.hotelCity ?? '',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Check-in', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  booking.checkIn != null ? DateFormat('d MMM yyyy', 'id_ID').format(booking.checkIn!) : '-',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const Text('Mulai 14:00 WIB', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Check-out', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  booking.checkOut != null ? DateFormat('d MMM yyyy', 'id_ID').format(booking.checkOut!) : '-',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const Text('Sebelum 12:00 WIB', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipe Kamar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(booking.roomName ?? 'Deluxe Room', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Nama Tamu', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(booking.guestName ?? 'Tamu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
