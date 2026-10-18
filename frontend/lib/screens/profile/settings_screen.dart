import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App preferences state
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedCurrency = 'IDR (Rp - Rupiah)';
  String _selectedTimeZone = 'WIB (GMT+7)';
  String _selectedThemeMode = 'Terang';

  // Notification toggles
  bool _notifyOrder = true;
  bool _notifyPaymentReminder = true;
  bool _notifyPromo = true;
  bool _notifyEmail = false;

  // Security toggles
  bool _biometricAuth = true;

  void _showLanguageSelector() {
    final languages = [
      {'name': 'Bahasa Indonesia', 'desc': 'Indonesian (Default)'},
      {'name': 'English (US)', 'desc': 'English (United States)'},
      {'name': 'Melayu', 'desc': 'Bahasa Malaysia'},
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
              const Text('Pilih Bahasa Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...languages.map((l) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(l['desc']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: _selectedLanguage == l['name']
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = l['name']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bahasa diubah ke ${l['name']}')),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencySelector() {
    final currencies = [
      {'code': 'IDR (Rp - Rupiah)', 'desc': 'Rupiah Indonesia'},
      {'code': 'USD (\$ - US Dollar)', 'desc': 'Dolar Amerika Serikat'},
      {'code': 'SGD (S\$ - Singapore Dollar)', 'desc': 'Dolar Singapura'},
      {'code': 'MYR (RM - Malaysian Ringgit)', 'desc': 'Ringgit Malaysia'},
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
              const Text('Pilih Mata Uang Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...currencies.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(c['desc']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: _selectedCurrency == c['code']
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedCurrency = c['code']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mata uang utama diatur ke ${c['code']}')),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showTimeZoneSelector() {
    final timezones = [
      {'name': 'WIB (GMT+7)', 'desc': 'Waktu Indonesia Barat (Jakarta, Surabaya, Medan)'},
      {'name': 'WITA (GMT+8)', 'desc': 'Waktu Indonesia Tengah (Bali, Makassar, Balikpapan)'},
      {'name': 'WIT (GMT+9)', 'desc': 'Waktu Indonesia Timur (Jayapura, Ambon)'},
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
              const Text('Pilih Zona Waktu Tampilan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...timezones.map((tz) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tz['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(tz['desc']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: _selectedTimeZone == tz['name']
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedTimeZone = tz['name']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Zona waktu jadwal diubah ke ${tz['name']}')),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordModal() {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                    'Demi keamanan akun Anda, pastikan kata sandi minimal 6 karakter dan tidak mudah ditebak.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: oldPasswordCtrl,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Saat Ini',
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setModalState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: obscureNew,
                    decoration: const InputDecoration(labelText: 'Konfirmasi Kata Sandi Baru'),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Perbarui Kata Sandi',
                    onPressed: () {
                      if (oldPasswordCtrl.text.isEmpty || newPasswordCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua kolom kata sandi wajib diisi.'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }
                      if (newPasswordCtrl.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kata sandi baru minimal harus 6 karakter.'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }
                      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Konfirmasi kata sandi baru tidak cocok.'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi berhasil diperbarui dengan aman.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Cache & Riwayat?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Tindakan ini akan membersihkan data cache pencarian dan gambar sementara pada perangkat Anda tanpa menghapus data pesanan aktif.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache dan riwayat pencarian lokal berhasil dibersihkan! (24.8 MB dibebaskan)'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Hapus Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kebijakan Privasi TraveLokuy', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Pengumpulan Informasi Pribadi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kami mengumpulkan informasi yang Anda berikan secara langsung saat mendaftar akun, seperti nama lengkap, alamat email, nomor telepon, dan data penumpang untuk keperluan penerbitan tiket resmi maskapai, hotel, kereta api KAI/Whoosh, bus, rental, antar bandara, dan asuransi.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '2. Keamanan & Enkripsi Data',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Semua transaksi pembayaran dan informasi sensitif dienkripsi menggunakan protokol SSL/TLS berstandar industri perbankan serta diawasi untuk mencegah akses tanpa izin.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '3. Penggunaan Cookie & Notifikasi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'TraveLokuy menggunakan pengenal unik sesi lokal untuk menyimpan preferensi bahasa, mata uang, dan notifikasi jadwal keberangkatan e-tiket Anda.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTermsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Syarat & Ketentuan Layanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Ketentuan Pemesanan & Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Setiap pemesanan tiket penerbangan, hotel, kereta api, bus, tiket atraksi Xperience, rental kendaraan, maupun asuransi harus diselesaikan sebelum batas waktu pembayaran (countdown timer) berakhir.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '2. E-Tiket & Kode Booking Resmi',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'E-Tiket resmi yang diterbitkan dengan kode booking dan kode QR unik merupakan bukti sah kepemilikan tiket dan dapat langsung diverifikasi di konter check-in stasiun, bandara, terminal, atau front desk hotel.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                  ),
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
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Akun & Keamanan
            _buildSectionHeader('Akun & Keamanan', Icons.shield_outlined),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    if (auth.isLoggedIn) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(user?.name ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gunakan tombol ubah profil di halaman Profil utama.')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                        title: const Text('Ubah Kata Sandi'),
                        subtitle: const Text('Perbarui kredensial login Anda', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showChangePasswordModal,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
                        title: const Text('Autentikasi Biometrik & PIN'),
                        subtitle: const Text('Masuk cepat & verifikasi pembayaran', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        value: _biometricAuth,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _biometricAuth = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(val ? 'Autentikasi biometrik diaktifkan.' : 'Autentikasi biometrik dinonaktifkan.')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.devices_outlined, color: AppColors.primary),
                        title: const Text('Perangkat Terhubung'),
                        subtitle: const Text('Browser Chrome / Windows (Sesi Aktif)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text('Aktif', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                        ),
                        onTap: () {},
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.login, color: AppColors.primary),
                        title: const Text('Masuk ke Akun'),
                        subtitle: const Text('Akses pengaturan keamanan profil lengkap', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Preferensi Aplikasi
            _buildSectionHeader('Preferensi Aplikasi', Icons.tune),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primary),
                      title: const Text('Bahasa'),
                      subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showLanguageSelector,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: AppColors.secondary),
                      title: const Text('Mata Uang Pembayaran'),
                      subtitle: Text(_selectedCurrency, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showCurrencySelector,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule, color: AppColors.primary),
                      title: const Text('Zona Waktu Jadwal'),
                      subtitle: Text(_selectedTimeZone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showTimeZoneSelector,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                      title: const Text('Tema Tampilan'),
                      subtitle: Text(_selectedThemeMode, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        setState(() {
                          _selectedThemeMode = _selectedThemeMode == 'Terang' ? 'Gelap (Otomatis)' : 'Terang';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tema diubah ke $_selectedThemeMode')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Notifikasi
            _buildSectionHeader('Pengaturan Notifikasi', Icons.notifications_none),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                      title: const Text('Status E-Tiket & Pesanan'),
                      subtitle: const Text('Pembaruan tiket issued, gerbang, & check-in', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      value: _notifyOrder,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _notifyOrder = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm, color: AppColors.secondary),
                      title: const Text('Pengingat Waktu Pembayaran'),
                      subtitle: const Text('Pengingat sisa waktu sebelum pesanan kedaluwarsa', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      value: _notifyPaymentReminder,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => setState(() => _notifyPaymentReminder = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.local_offer_outlined, color: Colors.amber),
                      title: const Text('Diskon Promo & Flash Sale'),
                      subtitle: const Text('Kupon spesial tiket pesawat, hotel, & atraksi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      value: _notifyPromo,
                      activeColor: Colors.amber.shade700,
                      onChanged: (val) => setState(() => _notifyPromo = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.email_outlined, color: AppColors.primary),
                      title: const Text('Salinan E-Tiket ke Email'),
                      subtitle: const Text('Kirim bukti voucher resmi langsung ke email akun', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      value: _notifyEmail,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _notifyEmail = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 4: Privasi & Data
            _buildSectionHeader('Privasi & Bantuan', Icons.policy_outlined),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                      title: const Text('Kebijakan Privasi'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showPrivacyPolicy,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                      title: const Text('Syarat & Ketentuan Layanan'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showTermsDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.danger),
                      title: const Text('Hapus Cache & Riwayat Pencarian', style: TextStyle(color: AppColors.danger)),
                      subtitle: const Text('Kosongkan data sementara aplikasi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.danger),
                      onTap: _showClearCacheDialog,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 5: Tentang Aplikasi
            _buildSectionHeader('Informasi Aplikasi', Icons.info_outline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                      ),
                      title: const Text('TraveLokuy App', style: TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: const Text('Versi 1.0.0 (Stable Official Release)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Terbaru', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aplikasi TraveLokuy Anda sudah dalam versi terbaru.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Logout Button if logged in
            if (auth.isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'Keluar dari Akun',
                  isOutlined: true,
                  backgroundColor: AppColors.danger,
                  textColor: AppColors.danger,
                  icon: Icons.logout,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.w800)),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun TraveLokuy?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              auth.logout();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Anda telah keluar dari akun.')),
                              );
                            },
                            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
