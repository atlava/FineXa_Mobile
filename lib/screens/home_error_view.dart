import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/error_widgets.dart';

const _errorBg = Color(0xFF0B3A2F);

/// Error state Beranda: gagal terhubung ke server.
class HomeErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const HomeErrorView({super.key, required this.onRetry});

  Widget _box(IconData icon) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
            color: AppColors.lightCard, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: _errorBg),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _errorBg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onLongPress: () => toggleOfflineMode(context),
                    child: _box(Icons.trending_up),
                  ),
                  const Text('Beranda',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _box(Icons.notifications),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFA000), shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4A3C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4.5, backgroundColor: Color(0xFFFFB020)),
                    SizedBox(width: 8),
                    Text('Koneksi Terputus',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4033),
                  borderRadius: BorderRadius.circular(46),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(size: const Size(112, 112), painter: _DashedCircle()),
                        Icon(Icons.smart_toy_outlined,
                            size: 58, color: AppColors.emerald.withValues(alpha: 0.55)),
                        Positioned(
                          right: -22,
                          bottom: -14,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _errorBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.emerald, width: 2),
                            ),
                            child: const Icon(Icons.wifi_off,
                                color: AppColors.emerald, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Yah, Gagal Terhubung ke Server',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: Colors.white)),
              const SizedBox(height: 12),
              const Text(
                'Kami tidak dapat memuat data portofolio dan insight AI Anda karena gangguan koneksi atau server sedang dalam pemeliharaan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.65, color: Color(0xFF8FC4B3)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52D1A5),
                                    foregroundColor: _errorBg,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  child: const Text('Muat Ulang'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                      content: Text('Periksa Wi-Fi atau data seluler perangkat Anda.'))),
                child: const Text('Periksa Jaringan Anda',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8FC4B3))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final rect = (Offset.zero & size).deflate(3);
    const n = 9;
    const seg = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(rect, i * seg, seg * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
