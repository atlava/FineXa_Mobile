import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _emailError;
  String? _passError;
  bool _isLoading = false; // Tambahan untuk indikator loading
  String? _bannerTitle; // Error state: banner di atas form
  String? _bannerMsg;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1. Validasi form lokal
    setState(() {
      _bannerTitle = null;
      _bannerMsg = null;
      _emailError = _emailRe.hasMatch(_email.text.trim())
          ? null
          : 'Format email tidak valid (contoh: nama@email.com)';
      _passError = _pass.text.isEmpty ? 'Ups! Password belum diisi' : null;
    });

    if (_emailError != null || _passError != null) return;

    // 2. Mulai proses login ke server
    setState(() {
      _isLoading = true;
    });

    try {
      // Sesuaikan URL dengan route Express-mu
      // Jika pakai emulator Android, gunakan 10.0.2.2
      // Simulasi offline untuk demo error state
      if (AppState.offline.value) throw Exception('Simulasi offline aktif');

      final url = Uri.parse('http://10.0.2.2:5000/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email.text.trim(),
          'password': _pass.text,
          'platform': 'mobile', // Sesuai permintaan backend untuk validasi role
        }),
      );

      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && responseData['success'] == true) {
        // 3. Login berhasil! Ambil token dari respons
        final String token = responseData['data']['token'];
        final int userId = responseData['data']['id_user'];
        // 4. Simpan token ke memori lokal HP (Shared Preferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setInt('user_id', userId);

        // 5. Pindah ke halaman utama dan lempar ID aslinya
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainShell(userId: userId.toString())),
        );
      } else {
        // Jika server menolak (email/password salah) -> banner error
        setState(() {
          _bannerTitle = 'Login gagal';
          _bannerMsg = responseData['message']?.toString() ?? 'Email atau password salah.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bannerTitle = 'Koneksi bermasalah';
        _bannerMsg = 'Gagal terhubung ke server. Pastikan backend menyala.';
      });
      debugPrint("Error Login Flutter: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const FinexaLogo(),
                const SizedBox(height: 48),
                const Text('Selamat Datang\nKembali!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 28),
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
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  controller: _pass,
                  obscure: true,
                  errorText: _passError,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordScreen(initialEmail: _email.text.trim()),
                      ),
                    ),
                    child: const Text('Lupa password?',
                        style: TextStyle(color: AppColors.emerald, fontSize: 11)),
                  ),
                ),
                const SizedBox(height: 12),

                // Ganti tombol dengan indikator loading saat memproses
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
                    : PrimaryButton(label: 'Login', onPressed: _login),

                const SizedBox(height: 14),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Belum punya akun? ',
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('Daftar sekarang',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.emerald,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}