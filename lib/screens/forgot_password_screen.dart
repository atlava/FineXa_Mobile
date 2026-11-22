import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'verify_code_screen.dart';

/// Langkah 1: masukkan email, lalu kirim kode verifikasi.
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email;
  String? _emailError;
  String? _bannerTitle;
  String? _bannerMsg;
  bool _loading = false;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    setState(() {
      _bannerTitle = null;
      _bannerMsg = null;
      _emailError = _emailRe.hasMatch(email)
          ? null
          : 'Format email tidak valid (contoh: nama@email.com)';
    });
    if (_emailError != null) return;

    setState(() => _loading = true);
    final result = await PasswordResetService.sendCode(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email)));
    } else {
      setState(() {
        _bannerTitle = result.networkError ? 'Koneksi bermasalah' : 'Gagal mengirim kode';
        _bannerMsg = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.lock_reset,
      title: 'Lupa Password?',
      subtitle:
          'Tenang, masukkan email yang terdaftar. Kami akan mengirimkan kode verifikasi 6 digit ke email Anda.',
      children: [
        if (_bannerMsg != null) ...[
          ErrorBanner(title: _bannerTitle!, message: _bannerMsg!),
          const SizedBox(height: 16),
        ],
        AppTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
        ),
        const SizedBox(height: 24),
        _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : PrimaryButton(label: 'Kirim Kode', onPressed: _send),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            children: [
              const Text('Ingat password? ',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Masuk di sini',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
