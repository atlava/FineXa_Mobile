import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'home_error_view.dart';
import 'questionnaire_screen.dart';
import 'investment_products_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToFaq;
  // TODO: Pastikan userId ini diisi dari MainShell saat login!
  final String userId;

  const HomeScreen({
    super.key,
    required this.onGoToFaq,
    this.userId = '1', // Default sementara untuk testing, ganti dengan ID user asli nanti
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasError = false; // true saat gagal terhubung ke server

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // Saklar simulasi offline (long-press logo) -> muat ulang data
    AppState.offline.addListener(_reload);
  }

  @override
  void dispose() {
    AppState.offline.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Simulasi offline untuk demo error state
      if (AppState.offline.value) throw Exception('Simulasi offline aktif');

      // Catatan: 10.0.2.2 adalah IP khusus emulator Android untuk mengakses localhost PC
      final url = Uri.parse('http://10.0.2.2:5000/api/beranda/user-profile/${widget.userId}');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['profil_risiko'] != null) {
          final profilStr = data['profil_risiko'].toString().toLowerCase();
          if (profilStr.contains('agresif')) {
            AppState.risk.value = RiskType.agresif;
          } else if (profilStr.contains('konservatif')) {
            AppState.risk.value = RiskType.konservatif;
          } else {
            AppState.risk.value = RiskType.moderat;
          }
        } else {
          AppState.risk.value = null;
        }
      } else if (response.statusCode >= 500) {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      _hasError = true; // tampilkan error state (setState ada di finally)
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startQuiz(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const QuestionnaireScreen()));

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    // Error state: gagal terhubung ke server
    if (_hasError) {
      return HomeErrorView(onRetry: _reload);
    }

    return ValueListenableBuilder<RiskType?>(
      valueListenable: AppState.risk,
      builder: (context, risk, _) {
        return SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  children: [
                    risk == null ? _empty(context) : _filledContent(context, risk),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Empty state ----------
  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 110),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.folder_open, size: 56, color: AppColors.emerald),
          ),
          const SizedBox(height: 20),
          const Text('Portofoliomu masih kosong, nih.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Yuk, cari tahu profil risikomu dan dapatkan saran alokasi investasi yang sesuai gaya hidupmu!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 40),
          PrimaryButton(label: 'Mulai Analisis Sekarang', onPressed: () => _startQuiz(context)),
        ],
      ),
    );
  }

  // ---------- Filled content ----------
  Widget _filledContent(BuildContext context, RiskType type) {
    final info = RiskData.info[type]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.7)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Datang di FineXa! 👋',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4),
              Text(
                'Mulai perjalanan investasi Anda dengan rekomendasi yang disesuaikan dengan profil risiko dan tujuan finansial Anda.',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
        const _SectionTitle('Akses cepat'),
        Row(
          children: [
            _QuickTile(
              icon: Icons.pie_chart_outline,
              label: 'Produk Investasi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InvestmentProductsScreen(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _QuickTile(
                icon: Icons.show_chart,
                label: 'Saran Investasi',
                onTap: () => _startQuiz(context)),
            const SizedBox(width: 10),
            _QuickTile(icon: Icons.school_outlined, label: 'FAQ', onTap: widget.onGoToFaq),
          ],
        ),
        const SizedBox(height: 12),
        LightCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFD5E3DF),
                child: Icon(Icons.shield_outlined, color: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profil risiko kamu', style: TextStyle(fontSize: 10)),
                    Text(info.label,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(info.desc, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _SectionTitle('Komposisi portofolio'),
        LightCard(
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutPainter(
                    info.allocations.map((e) => e.pct.toDouble()).toList(),
                    info.allocations.map((e) => e.color).toList(),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TOTAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600)),
                        Text('100%',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: info.allocations
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                            width: 7,
                            height: 7,
                            decoration:
                            BoxDecoration(color: e.color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(e.name, style: const TextStyle(fontSize: 9))),
                        Text('${e.pct}%',
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const LightCard(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.emerald),
                SizedBox(width: 6),
                Text('Insight Finexa AI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
              SizedBox(height: 6),
              Text(
                'Portofoliomu tumbuh stabil. Pertimbangkan diversifikasi berkala untuk menjaga keseimbangan.',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        const _SectionTitle('Tips Investasi'),
        const _TipCard('Diversifikasi Portofolio',
            'Jangan menaruh semua telur dalam satu keranjang. Sebarkan investasi Anda ke berbagai instrumen untuk mengurangi risiko.'),
        const _TipCard('Investasi Jangka Panjang',
            'Investasi terbaik adalah yang dilakukan secara konsisten dalam jangka waktu panjang. Bersabar adalah kunci kesuksesan.'),
        const _TipCard('Pahami Profil Risiko',
            'Kenali toleransi risiko Anda sebelum berinvestasi. Investasi yang tepat adalah yang sesuai dengan kondisi finansial Anda.'),
        const _TipCard('Review Berkala',
            'Evaluasi portofolio investasi Anda secara rutin dan sesuaikan strategi berdasarkan perubahan kondisi pasar dan tujuan finansial.'),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _startQuiz(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ulangi Asesmen', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tahan lama logo = ON/OFF simulasi offline (khusus demo error state)
          GestureDetector(
            onLongPress: () => toggleOfflineMode(context),
            child: const _IconBox(Icons.trending_up),
          ),
          const Text('Beranda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const _IconBox(Icons.notifications_none),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: AppColors.iconBox, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.bgTop),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 18, 0, 8),
    child: Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
  );
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: LightCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(icon, size: 16, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String desc;
  const _TipCard(this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return LightCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(desc, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = values.fold<double>(0, (a, b) => a + b);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}