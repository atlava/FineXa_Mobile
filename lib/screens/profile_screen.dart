import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId; // Menerima userId dari MainShell
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nama = 'Memuat...';
  String _email = 'Memuat...';
  String _noTelepon = 'Belum diatur';
  String _lokasi = 'Belum diatur';
  String _tanggalLahir = 'Belum diatur';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/users/${widget.userId}');
      print('DEBUG URL: $url');
      final response = await http.get(url);
      print('DEBUG STATUS: ${response.statusCode}');
      print('DEBUG BODY: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'];

        setState(() {
          _nama = data['nama_lengkap'] ?? 'Tanpa Nama';
          _email = data['email'] ?? 'Tidak ada email';
          _noTelepon = data['no_telepon'] ?? 'Belum diatur';
          _lokasi = data['lokasi'] ?? 'Belum diatur';
          _tanggalLahir = data['tanggal_lahir'] ?? 'Belum diatur';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetch profile: $e');
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: LightCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kamu yakin ingin keluar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('Sesi Anda akan diakhiri dan perlu login kembali.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.textDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx); // Tutup dialog konfirmasi dulu
                      await _performLogout(); // Panggil fungsi logout API & pindah screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Ya, Keluar'),
                  ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
          : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text('Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  width: double.infinity,
                  child: LightCard(
                    padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
                    child: Column(
                      children: [
                        Text(_nama,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('Member FineXa', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFD0D0D0), shape: BoxShape.circle),
                  child: Text(_nama.isNotEmpty ? _nama[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LightCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Informasi Pribadi',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(), // <-- Hubungkan ke fungsi baru
                        icon: const Icon(Icons.edit, size: 12),
                        label: const Text('Edit', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: const BorderSide(color: AppColors.textDark),
                          minimumSize: const Size(0, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _Info('Email', _email)),
                      Expanded(child: _Info('Nomor Telepon', _noTelepon)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _Info('Lokasi', _lokasi)),
                      Expanded(child: _Info('Tanggal Lahir', _tanggalLahir)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Profil Investasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            ValueListenableBuilder<RiskType?>(
              valueListenable: AppState.risk,
              builder: (_, risk, _) {
                final info = risk == null ? null : RiskData.info[risk];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _InvestTile('Profil Risiko', info?.label ?? '-'),
                          const SizedBox(height: 10),
                          _InvestTile('Horizon Investasi', info?.horizon ?? '-'),                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InvestTile('Target Return', info?.expectedReturn ?? '-',
                          tall: true),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => _confirmLogout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengirim data PUT ke Backend Express dengan Validasi Client
  Future<void> _updateProfileData(
      String name, String email, String phone, String location, String dob) async {

    // Validasi Client-Side
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong!')),
      );
      return;
    }
    if (!email.contains('@') || !email.endsWith('.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email harus mengandung "@" dan berakhiran ".com"!')),
      );
      return;
    }
    if (phone.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon harus berupa angka!')),
      );
      return;
    }

    try {
      // Simulasi offline untuk demo error state
      if (AppState.offline.value) throw Exception('Simulasi offline aktif');

      final url = Uri.parse('http://10.0.2.2:5000/api/users/${widget.userId}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': name,
          'email': email,
          'no_telepon': phone.isEmpty ? null : phone,
          'lokasi': location.isEmpty ? null : location,
          'tanggal_lahir': dob.isEmpty ? null : dob,
        }),
      ).timeout(const Duration(seconds: 15));

      // Server error (500 dst) -> error state
      if (response.statusCode >= 500) {
        throw Exception('Server error ${response.statusCode}');
      }

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Profil berhasil diperbarui!')),
        );
        _fetchProfileData(); // Refresh data agar tampilan di layar ikut berubah
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memperbarui profil.')),
        );
      }
    } catch (e) {
      debugPrint('Error update profile: $e');
      if (!mounted) return;
      // Error state: gagal menyimpan (timeout / server error / koneksi putus)
      showBlurDialog(
        context,
        builder: (ctx) => SaveFailedDialog(
          onRetry: () {
            Navigator.pop(ctx);
            _updateProfileData(name, email, phone, location, dob);
          },
          onClose: () => Navigator.pop(ctx),
        ),
      );
    }
  }

  // Fungsi untuk menampilkan Bottom Sheet form edit profil
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _nama);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _noTelepon == 'Belum diatur' ? '' : _noTelepon);
    final locationController = TextEditingController(text: _lokasi == 'Belum diatur' ? '' : _lokasi);
    final dobController = TextEditingController(text: _tanggalLahir == 'Belum diatur' ? '' : _tanggalLahir);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF14574A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Profil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 16),
                _buildTextField('Nama Lengkap', nameController),
                const SizedBox(height: 12),
                _buildTextField('Email', emailController),
                const SizedBox(height: 12),
                _buildTextField('Nomor Telepon', phoneController),
                const SizedBox(height: 12),
                _buildTextField('Lokasi', locationController),
                const SizedBox(height: 12),
                _buildTextField('Tanggal Lahir (YYYY-MM-DD)', dobController),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Tutup dialog dulu
                      Navigator.pop(ctx);
                      // Panggil fungsi update data
                      await _updateProfileData(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                        locationController.text,
                        dobController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk kotak teks form
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/auth/logout');

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      AppState.risk.value = null;
      AppState.offline.value = false; // reset simulasi offline

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
        );
      }
    } catch (e) {
      debugPrint('Error logout: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
        );
      }
    }
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _InvestTile extends StatelessWidget {
  final String label;
  final String value;
  final bool tall;
  const _InvestTile(this.label, this.value, {this.tall = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1FA84F))),
      ],
    );
    return SizedBox(
      width: double.infinity,
      height: tall ? 110 : 50,
      child: LightCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: content,
      ),
    );
  }
}