import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/train_provider.dart';
import '../../widgets/train_card.dart';
import 'train_booking_screen.dart';

class TrainResultsScreen extends StatelessWidget {
  const TrainResultsScreen({super.key});

  void _showSortModal(BuildContext context) {
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final sortOptions = [
      {'key': 'price_asc', 'label': 'Harga Terendah (Termurah)'},
      {'key': 'price_desc', 'label': 'Harga Tertinggi'},
      {'key': 'time_asc', 'label': 'Waktu Berangkat Paling Awal'},
      {'key': 'time_desc', 'label': 'Waktu Berangkat Paling Akhir'},
      {'key': 'duration_asc', 'label': 'Durasi Perjalanan Tercepat'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Urutkan Berdasarkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = trainProvider.sortBy == opt['key'];
                return RadioListTile<String>(
                  title: Text(
                    opt['label']!,
                    style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                  ),
                  value: opt['key']!,
                  groupValue: trainProvider.sortBy,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      trainProvider.setSortBy(val);
                      Navigator.pop(ctx);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final trainProvider = Provider.of<TrainProvider>(context, listen: false);
    final classes = ['Semua Kelas', 'Eksekutif', 'Bisnis', 'Ekonomi', 'Kereta Cepat'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String? currentClass = trainProvider.selectedClass;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Kelas Kereta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...classes.map((c) {
                final isSelected = (c == 'Semua Kelas' && currentClass == null) || (c == currentClass);
                return RadioListTile<String?>(
                  title: Text(c, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  value: c == 'Semua Kelas' ? null : c,
                  groupValue: currentClass,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    trainProvider.setClassFilter(val);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainProvider = Provider.of<TrainProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trainProvider.originStation?.code ?? 'GMR'} ➔ ${trainProvider.destStation?.code ?? 'BD'} (${trainProvider.originStation?.cityName ?? 'Jakarta'} - ${trainProvider.destStation?.cityName ?? 'Bandung'})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${DateFormat('d MMM yyyy', 'id_ID').format(trainProvider.departureDate)} • ${trainProvider.passengersCount} Penumpang',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Urutkan',
            onPressed: () => _showSortModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Kelas',
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: trainProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainProvider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(trainProvider.errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => trainProvider.searchTrains(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : trainProvider.trains.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.train_outlined, size: 54, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Kereta Tidak Ditemukan',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tidak ada jadwal kereta pada rute atau filter yang dipilih. Coba ganti stasiun atau reset filter kelas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filter & Cari Ulang'),
                              onPressed: () {
                                trainProvider.setClassFilter(null);
                                trainProvider.searchTrains();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trainProvider.trains.length,
                      itemBuilder: (context, i) {
                        final train = trainProvider.trains[i];
                        return TrainCard(
                          train: train,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrainBookingScreen(
                                  train: train,
                                  passengersCount: trainProvider.passengersCount,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
