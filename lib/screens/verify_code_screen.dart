import 'dart:async';
import 'package:flutter/material.dart';
import '../services/password_reset_service.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'reset_password_screen.dart';

/// Langkah 2: masukkan kode 6 digit yang dikirim ke email.
class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _otp = TextEditingController();
  final _focus = FocusNode();
  String? _codeError;
  String? _bannerTitle;
  String? _bannerMsg;
  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _countdown {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    final code = _otp.text;
    if (code.length < 6) {
      setState(() => _codeError = 'Masukkan 6 digit kode ya');
      return;
    }
    setState(() {
      _loading = true;
      _codeError = null;
      _bannerTitle = null;
      _bannerMsg = null;
    });
    final result = await PasswordResetService.verifyCode(widget.email, code);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: widget.email, code: code)),
      );
    } else if (result.networkError) {
      setState(() {
        _bannerTitle = 'Koneksi bermasalah';
        _bannerMsg = result.message;
      });
    } else {
      setState(() => _codeError = 'Ups! Kode kurang tepat atau sudah kedaluwarsa. Coba lagi, ya');
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _loading) return;
    setState(() {
      _loading = true;
      _bannerTitle = null;
      _bannerMsg = null;
    });
    final result = await PasswordResetService.sendCode(widget.email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      setState(() {
        _codeError = null;
        _otp.clear();
        _startTimer();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Kode baru sudah dikirim ke email Anda')));
    } else {
      setState(() {
        _bannerTitle = result.networkError ? 'Koneksi bermasalah' : 'Gagal mengirim kode';
        _bannerMsg = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_loading;
    return AuthScaffold(
      icon: Icons.mark_email_unread_outlined,
      title: 'Cek Email Anda',
      subtitle:
          'Kami mengirim kode 6 digit ke ${maskEmail(widget.email)}. Cek juga folder spam jika belum masuk.',
      children: [
        if (_bannerMsg != null) ...[
          ErrorBanner(title: _bannerTitle!, message: _bannerMsg!),
          const SizedBox(height: 16),
        ],
        OtpInput(
          controller: _otp,
          focusNode: _focus,
          hasError: _codeError != null,
          onChanged: (_) {
            if (_codeError != null) setState(() => _codeError = null);
          },
        ),
        if (_codeError != null) InlineError(_codeError!),
        if (PasswordResetService.useMock) ...[
          const SizedBox(height: 12),
          Text('Mode contoh: gunakan kode ${PasswordResetService.mockCode}',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
        ],
        const SizedBox(height: 24),
        _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : PrimaryButton(label: 'Verifikasi', onPressed: _verify),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: canResend ? _resend : null,
            child: Text(
              canResend ? 'Kirim ulang kode' : 'Kirim ulang kode dalam $_countdown',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: canResend ? AppColors.emerald : Colors.white54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
