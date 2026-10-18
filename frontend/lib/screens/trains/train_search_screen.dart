import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/train_provider.dart';
import '../../widgets/custom_button.dart';
import 'train_results_screen.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<TrainProvider>(context, listen: false);
      if (p.stations.isEmpty) {
        p.fetchStations();
      }
    });
  }

  void _showStationPicker(BuildContext context, bool isOrigin) {
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final stations = trainProvider.stations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = stations.where((s) {
              final q = searchQuery.toLowerCase();
              return s.name.toLowerCase().contains(q) ||
                  s.code.toLowerCase().contains(q) ||
                  s.cityName.toLowerCase().contains(q) ||
                  s.type.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isOrigin ? 'Pilih Stasiun Asal' : 'Pilih Stasiun Tujuan',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari stasiun atau kota (misal: Gambir, Halim, Bandung)...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Stasiun tidak ditemukan'))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final s = filtered[i];
                              final isWhoosh = s.isWhoosh;
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isWhoosh
                                        ? const Color(0xFFFFECEF)
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isWhoosh ? Icons.speed_rounded : Icons.train_rounded,
                                    color: isWhoosh ? const Color(0xFFC00A27) : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.name,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isWhoosh
                                            ? const Color(0xFFFFECEF)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        s.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isWhoosh ? const Color(0xFFC00A27) : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  '${s.cityName} • ${isWhoosh ? 'Kereta Cepat Whoosh' : 'KAI Antarkota'}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                onTap: () {
                                  if (isOrigin) {
                                    trainProvider.setOriginStation(s);
                                  } else {
                                    trainProvider.setDestStation(s);
                                  }
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPassengerPicker(BuildContext context) {
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    int count = trainProvider.passengersCount;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jumlah Penumpang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Maksimal 4 penumpang per pemesanan', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dewasa (3+ tahun)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 28),
                            onPressed: count > 1 ? () => setState(() => count--) : null,
                          ),
                          Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
                            onPressed: count < 4 ? () => setState(() => count++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Selesai',
                    onPressed: () {
                      trainProvider.setPassengersCount(count);
                      Navigator.pop(ctx);
                    },
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
    final trainProvider = Provider.of<TrainProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Kereta Api', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Origin Stasiun
                          InkWell(
                            onTap: () => _showStationPicker(context, true),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: trainProvider.originStation?.isWhoosh == true
                                          ? const Color(0xFFFFECEF)
                                          : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      trainProvider.originStation?.isWhoosh == true
                                          ? Icons.speed_rounded
                                          : Icons.train_rounded,
                                      color: trainProvider.originStation?.isWhoosh == true
                                          ? const Color(0xFFC00A27)
                                          : AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Dari', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          trainProvider.originStation != null
                                              ? '${trainProvider.originStation!.name} (${trainProvider.originStation!.code})'
                                              : 'Pilih Stasiun Asal',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          trainProvider.originStation?.cityName ?? '',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Swap Button Row
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Icon(Icons.swap_vert, color: AppColors.primary, size: 20),
                                ),
                                onPressed: () => trainProvider.swapStations(),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          // Destination Stasiun
                          InkWell(
                            onTap: () => _showStationPicker(context, false),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: trainProvider.destStation?.isWhoosh == true
                                          ? const Color(0xFFFFECEF)
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      trainProvider.destStation?.isWhoosh == true
                                          ? Icons.speed_rounded
                                          : Icons.train_rounded,
                                      color: trainProvider.destStation?.isWhoosh == true
                                          ? const Color(0xFFC00A27)
                                          : AppColors.secondary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Ke', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          trainProvider.destStation != null
                                              ? '${trainProvider.destStation!.name} (${trainProvider.destStation!.code})'
                                              : 'Pilih Stasiun Tujuan',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          trainProvider.destStation?.cityName ?? '',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 24),

                          // Date & Passenger Selectors
                          Row(
                            children: [
                              // Date
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: trainProvider.departureDate,
                                      firstDate: now,
                                      lastDate: now.add(const Duration(days: 90)),
                                    );
                                    if (picked != null) {
                                      trainProvider.setDepartureDate(picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Berangkat', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                DateFormat('EEE, d MMM yyyy', 'id_ID').format(trainProvider.departureDate),
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Container(width: 1, height: 40, color: Colors.grey.shade200),
                              const SizedBox(width: 8),

                              // Passengers
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showPassengerPicker(context),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Penumpang', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${trainProvider.passengersCount} Orang',
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Search CTA Button
                          CustomButton(
                            text: 'Cari Kereta Api',
                            icon: Icons.search,
                            onPressed: () async {
                              await trainProvider.searchTrains();
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider.value(
                                      value: trainProvider,
                                      child: const TrainResultsScreen(),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Class Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Kelas Kereta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildClassChip(null, 'Semua Kelas', trainProvider),
                        const SizedBox(width: 8),
                        _buildClassChip('Kereta Cepat', '⚡ Whoosh Cepat', trainProvider),
                        const SizedBox(width: 8),
                        _buildClassChip('Eksekutif', 'Eksekutif', trainProvider),
                        const SizedBox(width: 8),
                        _buildClassChip('Bisnis', 'Bisnis', trainProvider),
                        const SizedBox(width: 8),
                        _buildClassChip('Ekonomi', 'Ekonomi', trainProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Popular Routes Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rute Kereta Populer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildPopularRoute(
                    title: 'Jakarta (Halim) ➔ Bandung (Tegalluar)',
                    badge: 'WHOOSH 45 MENIT',
                    badgeColor: const Color(0xFFC00A27),
                    desc: 'Kereta Cepat Pertama di Asia Tenggara • 350 km/jam',
                    originCode: 'HLM',
                    destCode: 'TGL',
                    provider: trainProvider,
                  ),
                  const SizedBox(height: 10),
                  _buildPopularRoute(
                    title: 'Jakarta (Gambir) ➔ Bandung',
                    badge: 'KAI ARGO PARAHYANGAN',
                    badgeColor: AppColors.primary,
                    desc: 'Pemandangan alam pegunungan Priangan yang indah',
                    originCode: 'GMR',
                    destCode: 'BD',
                    provider: trainProvider,
                  ),
                  const SizedBox(height: 10),
                  _buildPopularRoute(
                    title: 'Jakarta (Gambir) ➔ Yogyakarta',
                    badge: 'KAI TAKSAKA',
                    badgeColor: AppColors.secondary,
                    desc: 'Perjalanan nyaman ke kota budaya dan kuliner',
                    originCode: 'GMR',
                    destCode: 'YK',
                    provider: trainProvider,
                  ),
                  const SizedBox(height: 10),
                  _buildPopularRoute(
                    title: 'Jakarta (Gambir) ➔ Surabaya Gubeng',
                    badge: 'ARGO BROMO ANGGREK',
                    badgeColor: Colors.deepPurple,
                    desc: 'Kereta unggulan lintas utara Jawa',
                    originCode: 'GMR',
                    destCode: 'SGU',
                    provider: trainProvider,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassChip(String? classType, String label, TrainProvider provider) {
    final isSelected = provider.selectedClass == classType;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade100,
      onSelected: (_) {
        provider.setClassFilter(classType);
      },
    );
  }

  Widget _buildPopularRoute({
    required String title,
    required String badge,
    required Color badgeColor,
    required String desc,
    required String originCode,
    required String destCode,
    required TrainProvider provider,
  }) {
    return InkWell(
      onTap: () {
        final origin = provider.stations.firstWhere(
          (s) => s.code == originCode,
          orElse: () => provider.stations.first,
        );
        final dest = provider.stations.firstWhere(
          (s) => s.code == destCode,
          orElse: () => provider.stations.last,
        );
        provider.setOriginStation(origin);
        provider.setDestStation(dest);
        provider.searchTrains();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: const TrainResultsScreen(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.train_rounded, color: badgeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
