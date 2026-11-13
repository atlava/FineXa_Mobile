import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../data/risk_data.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
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
                  label: 'Terapkan Rekomendasi',
                  icon: Icons.check,
                  onPressed: () {
//                  1. Konversi teks profil dari backend ke RiskType enum
                    final pLower = profil.toLowerCase();
                    if (pLower.contains('agresif')) {
                      AppState.risk.value = RiskType.agresif;
                    } else if (pLower.contains('konservatif')) {
                      AppState.risk.value = RiskType.konservatif;
                    } else {
                      AppState.risk.value = RiskType.moderat; // Default aman
                    }
                    // 2. Kembali ke halaman utama (MainShell)
                    Navigator.popUntil(context, (r) => r.isFirst);                  },
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