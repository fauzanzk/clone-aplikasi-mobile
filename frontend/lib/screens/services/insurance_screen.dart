import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/service_models.dart';
import '../../services/api_service.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final ApiService _apiService = ApiService();
  List<InsuranceModel> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getInsurances();
      setState(() {
        _plans = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showPurchaseSheet(InsuranceModel plan) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.planName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Pertanggungan Maksimal: ${plan.formattedCoverage}',
                  style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w700, fontSize: 13)),
              const Divider(height: 24),
              const Text('Manfaat Perlindungan Utama:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              ...plan.benefits.map((b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF00897B), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Premi Mulai', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        plan.formattedPrice,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Polis ${plan.planName} berhasil diaktifkan untuk perjalanan Anda!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Beli Polis Asuransi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asuransi Perjalanan', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF00897B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lindungi Liburan Tanpa Rasa Cemas',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kompensasi pembatalan mendadak, bagasi hilang, dan biaya medis luar kota atau luar negeri.',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildKeyBenefit(Icons.flash_on, 'Klaim Online 24/7'),
                      const SizedBox(width: 12),
                      _buildKeyBenefit(Icons.verified_user, 'OJK Terdaftar'),
                      const SizedBox(width: 12),
                      _buildKeyBenefit(Icons.card_travel, 'Perjalanan Aman'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Plan List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Polis Asuransi TraveLokuy Safe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: _plans.map((plan) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
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
                                          child: Text(
                                            plan.planName,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2F1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            plan.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF00695C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pertanggungan hingga ${plan.formattedCoverage}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF00897B),
                                      ),
                                    ),
                                    const Divider(height: 20),
                                    ...plan.benefits.take(3).map((b) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.check, size: 15, color: Color(0xFF00897B)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  b,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Premi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            Text(
                                              plan.formattedPrice,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00897B),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          ),
                                          onPressed: () => _showPurchaseSheet(plan),
                                          child: const Text('Pilih Paket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyBenefit(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
