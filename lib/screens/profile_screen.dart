import 'package:flutter/material.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      onPressed: () {
                        AppState.risk.value = null;
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (r) => false);
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
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
                child: const LightCard(
                  padding: EdgeInsets.fromLTRB(16, 52, 16, 16),
                  child: Column(
                    children: [
                      Text('Benny Saputra',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Member sejak Tahun 2026', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFD0D0D0), shape: BoxShape.circle),
                child: const Text('[foto]',
                    style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
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
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit profil segera hadir'))),
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
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _Info('Email', 'benny.saputra@gmail.com')),
                    Expanded(child: _Info('Nomor Telepon', '+62 812-3456-7890')),
                  ],
                ),
                const SizedBox(height: 14),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _Info('Lokasi', 'Jakarta, Indonesia')),
                    Expanded(child: _Info('Tanggal Lahir', '1 Januari 2000')),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _InvestTile('Profil Risiko', info?.label ?? '-'),
                        const SizedBox(height: 10),
                        _InvestTile('Horizon Investasi', info?.horizon ?? '-'),
                      ],
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
    );
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
