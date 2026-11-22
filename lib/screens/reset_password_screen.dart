import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';

/// Langkah 3: buat password baru.
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _passError;
  String? _confirmError;
  String? _bannerTitle;
  String? _bannerMsg;
  bool _loading = false;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _bannerTitle = null;
      _bannerMsg = null;
      _passError = _pass.text.length < 6 ? 'Password minimal 6 karakter ya' : null;
      _confirmError = _confirm.text != _pass.text
          ? 'Konfirmasi password tidak cocok dengan password utama'
          : null;
    });
    if (_passError != null || _confirmError != null) return;

    setState(() => _loading = true);
    final result =
        await PasswordResetService.resetPassword(widget.email, widget.code, _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      setState(() {
        _bannerTitle = result.networkError ? 'Koneksi bermasalah' : 'Gagal mengubah password';
        _bannerMsg = result.message;
      });
      return;
    }

    await showBlurDialog(
      context,
      builder: (ctx) => LightCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  const BoxDecoration(color: Color(0xFFC6EEE0), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 34, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            const Text('Password berhasil diubah',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Silakan login dengan password baru Anda.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Kembali ke Login', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.lock_outline,
      title: 'Buat Password Baru',
      subtitle: 'Kode terverifikasi. Silakan buat password baru untuk akun FineXa Anda.',
      children: [
        if (_bannerMsg != null) ...[
          ErrorBanner(title: _bannerTitle!, message: _bannerMsg!),
          const SizedBox(height: 16),
        ],
        AppTextField(
          label: 'Password Baru',
          controller: _pass,
          obscure: true,
          errorText: _passError,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Konfirmasi Password',
          controller: _confirm,
          obscure: true,
          errorText: _confirmError,
        ),
        const SizedBox(height: 28),
        _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : PrimaryButton(label: 'Simpan Password Baru', onPressed: _save),
      ],
    );
  }
}
