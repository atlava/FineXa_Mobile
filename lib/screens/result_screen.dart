import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../data/risk_data.dart';
import '../widgets/error_widgets.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saving = false;

  // Konversi teks profil dari backend ke RiskType enum
  RiskType _toRiskType(String profil) {
    final pLower = profil.toLowerCase();
    if (pLower.contains('agresif')) return RiskType.agresif;
    if (pLower.contains('konservatif')) return RiskType.konservatif;
    return RiskType.moderat; // Default aman
  }

  Future<void> _apply(String profil) async {
    setState(() => _saving = true);
    try {
      // Simulasi offline untuk demo error state
      if (AppState.offline.value) throw Exception('Simulasi offline aktif');

      // TODO: kirim "Terapkan Rekomendasi" ke server di sini, contoh:
      // final res = await http.post(Uri.parse('http://10.0.2.2:5000/api/...'), ...)
      //     .timeout(const Duration(seconds: 15));
      // if (res.statusCode >= 500) throw Exception('Server error');
      // Kalau request gagal / timeout, popup "Koneksi Terputus" otomatis muncul.

      if (!mounted) return;
      setState(() => _saving = false);

      // 1. Simpan profil risiko ke state aplikasi
      AppState.risk.value = _toRiskType(profil);
      // 2. Kembali ke halaman utama (MainShell)
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      debugPrint('Error apply rekomendasi: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      // Error state: gagal mengirim ke server
      showBlurDialog(
        context,
        builder: (ctx) => OfflineSaveDialog(
          onRetry: () {
            Navigator.pop(ctx);
            _apply(profil);
          },
          onNetworkSettings: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Aktifkan Wi-Fi/data seluler, lalu tekan Terapkan Rekomendasi lagi.')));
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultData = widget.resultData;
    // Menangkap data dari respons backend Express
    final String profil = resultData['profil_risiko']?.toString() ?? 'Moderat';
    final String expectedReturn = resultData['expected_return']?.toString() ?? '10 - 15% / tahun';
    final String horizon = resultData['horizon_waktu']?.toString() ?? '> 5 tahun';

    // Menangkap alokasi aset dari LLM Gemini
    final List<dynamic> alokasiRaw = resultData['alokasi_aset'] ?? [];

    List<AllocItem> allocItems = [];
    if (alokasiRaw.isNotEmpty) {
      final colors = [
        const Color(0xFF0F4F40),
        const Color(0xFF4B7BEC),
        const Color(0xFFE0A526),
        const Color(0xFF9AA5A0)
      ];
      for (int i = 0; i < alokasiRaw.length; i++) {
        final item = alokasiRaw[i];
        final name = item['nama']?.toString() ?? 'Aset';
        final pct = int.tryParse(item['persentase']?.toString() ?? '0') ?? 0;
        allocItems.add(AllocItem(name, pct, colors[i % colors.length]));
      }
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Saran Investasi Anda',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 28),
                LightCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.textDark),
                        ),
                        child: Text(
                          'PROFIL ${profil.toUpperCase()}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Berdasarkan jawaban Anda, Anda termasuk tipe investor ${profil.toLowerCase()}.',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _Stat('Expected Return', expectedReturn)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat('Horizon Waktu', horizon)),
                  ],
                ),
                const SizedBox(height: 16),
                LightCard(
                  child: Column(
                    children: [
                      const Text(
                        'Alokasi Aset yang Direkomendasikan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      allocItems.isNotEmpty
                          ? AllocationBars(items: allocItems)
                          : const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Memuat alokasi aset dari AI...',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: _saving ? 'Menyimpan...' : 'Terapkan Rekomendasi',
                  icon: _saving ? null : Icons.check,
                  onPressed: _saving ? null : () => _apply(profil),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: LightCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}