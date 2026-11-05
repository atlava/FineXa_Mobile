import 'package:flutter/material.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class ResultScreen extends StatelessWidget {
  final RiskType type;
  const ResultScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final info = RiskData.info[type]!;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text('Saran Investasi Anda',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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
                        child: Text('PROFIL ${info.label.toUpperCase()}',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Berdasarkan jawaban Anda, Anda termasuk tipe investor ${info.label.toLowerCase()}.',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _Stat('Expected Return', info.expectedReturn)),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat('Horizon Waktu', info.horizon)),
                  ],
                ),
                const SizedBox(height: 16),
                LightCard(
                  child: Column(
                    children: [
                      const Text('Alokasi Aset yang Direkomendasikan',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      AllocationBars(items: info.allocations),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Terapkan Rekomendasi',
                  icon: Icons.check,
                  onPressed: () {
                    AppState.risk.value = type;
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
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
            child: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
