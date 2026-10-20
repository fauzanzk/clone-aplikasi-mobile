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
    final isXperience = booking.type == 'XPERIENCE';
    final isCarRental = booking.type == 'CAR_RENTAL';
    final isAirportTransfer = booking.type == 'AIRPORT_TRANSFER';
    final isInsurance = booking.type == 'INSURANCE';

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
    } else if (isXperience) {
      screenTitle = 'Voucher Atraksi Xperience Resmi';
      headerBg = const Color(0xFFE91E63);
      headerIcon = Icons.attractions_rounded;
      screenBg = const Color(0xFFAD1457);
    } else if (isCarRental) {
      screenTitle = 'Voucher Sewa Mobil Resmi';
      headerBg = const Color(0xFF0097A7);
      headerIcon = Icons.directions_car_rounded;
      screenBg = const Color(0xFF006064);
    } else if (isAirportTransfer) {
      screenTitle = 'Voucher Antar Bandara Resmi';
      headerBg = const Color(0xFF3F51B5);
      headerIcon = Icons.airport_shuttle_rounded;
      screenBg = const Color(0xFF1A237E);
    } else if (isInsurance) {
      screenTitle = 'Polis Asuransi Perjalanan Resmi';
      headerBg = const Color(0xFF00897B);
      headerIcon = Icons.health_and_safety_rounded;
      screenBg = const Color(0xFF004D40);
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
                    child: (isFlight || isTrain || isBus)
                        ? _buildFlightDetails(booking)
                        : (isXperience || isCarRental || isAirportTransfer || isInsurance)
                            ? _buildServiceDetails(booking)
                            : _buildHotelDetails(booking),
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
                    Expanded(
                      child: Text(
                        '${p.title}. ${p.fullName}${p.idNumber.isNotEmpty ? ' (${p.idNumber})' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipe Kamar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                    booking.roomName ?? 'Deluxe Room',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Nama Tamu', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                    booking.guestName ?? 'Tamu',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceDetails(BookingModel booking) {
    final title = booking.itemName ?? booking.airline ?? 'Pesanan Layanan';
    final subtitle = booking.itemSubtitle ?? booking.flightNo ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking.paymentMethod ?? 'Virtual Account',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Waktu Transaksi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking.formattedDate,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      booking.formattedTotalPrice,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Voucher resmi ini valid & terverifikasi langsung oleh sistem TraveLokuy.',
                  style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
