import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';

/// Banner error di atas form (contoh: "Akun sudah ada: ...").
class ErrorBanner extends StatelessWidget {
  final String title;
  final String message;
  const ErrorBanner({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFB5645A).withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.white),
                children: [
                  TextSpan(
                      text: '$title: ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog dengan latar blur gelap (dipakai kedua popup error).
Future<T?> showBlurDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'dialog',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, a1, a2) => Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: builder(ctx),
              ),
            ),
          ),
        ],
      ),
    ),
    transitionBuilder: (ctx, anim, a2, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1).animate(anim),
        child: child,
      ),
    ),
  );
}

/// Error state: gagal menyimpan perubahan profil (error 500 / timeout).
class SaveFailedDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;
  const SaveFailedDialog({super.key, required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Color(0xFF1E293B)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xFFFDE2E2), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626), size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Gagal Menyimpan Perubahan',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF334155)),
                children: [
                  TextSpan(text: 'Terjadi kesalahan server saat menyimpan profil Anda '),
                  TextSpan(
                      text: '(Error 500 / Network Timeout)',
                      style: TextStyle(
                          color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                  TextSpan(text: '. Silakan periksa koneksi internet Anda.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                child: const Text('Batal / Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state: koneksi terputus saat menekan "Terapkan Rekomendasi".
class OfflineSaveDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onNetworkSettings;
  const OfflineSaveDialog(
      {super.key, required this.onRetry, required this.onNetworkSettings});

  static const _dark = Color(0xFF0B3A2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: _dark),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC6EEE0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF8EDFC4), width: 2),
                  ),
                  child: const Icon(Icons.wifi_off, size: 34, color: _dark),
                ),
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text('!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Ups, Koneksi Terputus!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text(
              'Jawaban asesmen risiko Anda sudah tersimpan di perangkat ini, namun gagal dikirim ke server. Pastikan koneksi internet aktif lalu coba kirim ulang.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.55, color: Color(0xFF2D5A4E)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFC9EFE1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF9EE0C8)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Text('Data aman di penyimpanan lokal',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.sync, size: 20),
                label: const Text('Coba Simpan Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AC8A8),
                  foregroundColor: _dark,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: onNetworkSettings,
              child: const Text('Cek Pengaturan Jaringan',
                  style: TextStyle(
                      color: _dark, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saklar simulasi offline (tahan lama logo di header Beranda).
/// Hapus saat sudah ada backend sungguhan.
void toggleOfflineMode(BuildContext context) {
  final next = !AppState.offline.value;
  AppState.offline.value = next;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 1500),
      content: Text(next ? 'Mode simulasi offline: AKTIF' : 'Mode simulasi offline: MATI'),
    ));
}
