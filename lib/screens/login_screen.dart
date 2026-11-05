import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'register_screen.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() {
    setState(() {
      _emailError = _email.text.trim().isEmpty ? 'Email belum diisi, ya' : null;
      _passError = _pass.text.length < 6 ? 'Ups! Password kurang tepat. Coba lagi, ya' : null;
    });
    if (_emailError == null && _passError == null) {
      // TODO: ganti dengan autentikasi sungguhan
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainShell()));
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
                    onPressed: () {},
                    child: const Text('Lupa password?',
                        style: TextStyle(color: AppColors.emerald, fontSize: 11)),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'Login', onPressed: _login),
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
