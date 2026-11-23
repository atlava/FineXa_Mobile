import 'package:flutter/material.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';
import 'main_shell.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _nameErr, _emailErr, _passErr, _confirmErr;
  String? _bannerTitle; // Error state: banner di atas form
  String? _bannerMsg;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _passwordRe =
  RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[~`!@#$%^=&_>,.</?\x27\x22:;}{|]).{8,}$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _nameErr = _name.text.trim().isEmpty ? 'Nama lengkap belum diisi, ya' : null;
      _bannerTitle = null;
      _bannerMsg = null;
      _emailErr = _emailRe.hasMatch(_email.text.trim())
          ? null
          : 'Format email tidak valid (contoh: nama@email.com)';
      _passErr = _passwordRe.hasMatch(_pass.text)
          ? null
          : 'Minimal 8 karakter (huruf besar, kecil, angka & simbol)';
      _confirmErr = _confirm.text != _pass.text
          ? 'Konfirmasi password tidak cocok dengan password utama'
          : null;
    });

    // SIMULASI (boleh dihapus): email berisi "sudahada" dianggap sudah terdaftar
    if (_email.text.trim().toLowerCase().contains('sudahada')) {
      setState(() {
        _bannerTitle = 'Akun sudah ada';
        _bannerMsg = 'Email sudah terdaftar. Silakan masuk atau gunakan email lain.';
      });
      return;
    }

    if ([_nameErr, _emailErr, _passErr, _confirmErr].every((e) => e == null)) {
      try {
        // Simulasi offline untuk demo error state
        if (AppState.offline.value) throw Exception('Simulasi offline aktif');

        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama_lengkap': _name.text.trim(),
            'email': _email.text.trim(),
            'password': _pass.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Tangkap ID user baru & token JWT dari respons JSON backend
          final int userIdRegister = data['data']['id_user'];
          final String? tokenRegister = data['data']['token'];

          // Simpan ke SharedPreferences agar kuesioner & halaman lain ter-autentikasi
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userIdRegister);
          if (tokenRegister != null) {
            await prefs.setString('jwt_token', tokenRegister);
          }

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainShell(userId: userIdRegister.toString()),
            ),
                (r) => false,
          );
        } else {
          // Tangani error dari server (misal: email sudah terdaftar)
          if (!mounted) return;
          final msg = data['message']?.toString() ?? 'Registrasi gagal, silakan coba lagi';
          final exists = response.statusCode == 409 ||
              msg.toLowerCase().contains('terdaftar') ||
              msg.toLowerCase().contains('sudah');
          setState(() {
            _bannerTitle = exists ? 'Akun sudah ada' : 'Registrasi gagal';
            _bannerMsg = exists
                ? 'Email sudah terdaftar. Silakan masuk atau gunakan email lain.'
                : msg;
          });
        }
      } catch (e) {
        if (!mounted) return;
        // Tangani error koneksi
        debugPrint('Error register: $e');
        setState(() {
          _bannerTitle = 'Koneksi bermasalah';
          _bannerMsg = 'Gagal terhubung ke server. Pastikan backend menyala.';
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
                const SizedBox(height: 56),
                const Text('Daftar',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 28),
                if (_bannerMsg != null) ...[
                  ErrorBanner(title: _bannerTitle!, message: _bannerMsg!),
                  const SizedBox(height: 16),
                ],
                AppTextField(label: 'Nama Lengkap', controller: _name, errorText: _nameErr),
                const SizedBox(height: 12),
                AppTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailErr),
                const SizedBox(height: 12),
                AppTextField(
                    label: 'Password', controller: _pass, obscure: true, errorText: _passErr),
                const SizedBox(height: 12),
                AppTextField(
                    label: 'Konfirmasi Password',
                    controller: _confirm,
                    obscure: true,
                    errorText: _confirmErr),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Daftar', onPressed: _register),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white54)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('atau daftar dengan',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                    ),
                    const Expanded(child: Divider(color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'Google', onPressed: () {}),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    children: [
                      const Text('Sudah punya akun? ',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}