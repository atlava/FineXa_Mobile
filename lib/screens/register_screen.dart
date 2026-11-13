import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // Pastikan Anda sudah mengimpor package http di bagian atas file:
  // import 'package:http/http.dart' as http;
  // import 'dart:convert';

  Future<void> _register() async {
    setState(() {
      _nameErr = _name.text.trim().isEmpty ? 'Nama lengkap belum diisi, ya' : null;
      _emailErr = !_email.text.contains('@') ? 'Format email belum sesuai, coba cek lagi ya' : null;
      _passErr = _pass.text.length < 6 ? 'Password minimal 6 karakter ya' : null;
      _confirmErr = _confirm.text != _pass.text ? 'Konfirmasi password belum sama, coba lagi ya' : null;
    });

    if ([_nameErr, _emailErr, _passErr, _confirmErr].every((e) => e == null)) {
      try {
        // Sesuaikan URL endpoint backend Laravel/Laragon Anda
        // Catatan: Jika menggunakan Android Emulator, gunakan 10.0.2.2 untuk mengakses localhost PC
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama_lengkap': _name.text.trim(),
            'email': _email.text.trim(),
            'password': _pass.text,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Jika registrasi berhasil ke database backend
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
                (r) => false,
          );
        } else {
          // Tangani error dari server (misal: email sudah terdaftar)
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Registrasi gagal, silakan coba lagi')),
          );
        }
      } catch (e) {
        // Tangani error koneksi (misal backend Laragon belum menyala)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Koneksi ke server gagal: $e')),
        );
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
