import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/risk_data.dart';

class ApiResult {
  final bool ok;
  final String message;
  final bool networkError;
  const ApiResult(this.ok, this.message, {this.networkError = false});
}

/// Layanan lupa password terintegrasi dengan FineXa-Admin-Express (/api/password)
class PasswordResetService {
  static const bool useMock = false;
  static const String mockCode = '123456';

  static const String _base = 'https://befinexaexpress-production.up.railway.app/api/password';

  /// 1. POST /api/password/request-otp -> body: {email}
  static Future<ApiResult> sendCode(String email) => _post(
    'request-otp',
    {'email': email.trim()},
    mock: () => const ApiResult(true, 'Kode verifikasi dikirim'),
  );

  /// 2. Validasi format kode 6 digit sebelum lanjut ke layar ganti password
  /// (Verifikasi token ke database dilakukan bersamaan saat submit /reset)
  static Future<ApiResult> verifyCode(String email, String code) async {
    if (AppState.offline.value) {
      return const ApiResult(
        false,
        'Gagal terhubung ke server. Pastikan koneksi internet dan backend aktif.',
        networkError: true,
      );
    }

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return code == mockCode
          ? const ApiResult(true, 'Kode benar')
          : const ApiResult(false, 'Kode salah atau sudah kedaluwarsa.');
    }

    final cleanCode = code.trim();
    if (cleanCode.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(cleanCode)) {
      return const ApiResult(false, 'Kode OTP harus terdiri dari 6 digit angka.');
    }

    return const ApiResult(true, 'Kode siap diverifikasi');
  }

  /// 3. POST /api/password/reset -> body: {email, token, password, confirm_password}
  static Future<ApiResult> resetPassword(
      String email,
      String code,
      String newPassword,
      ) =>
      _post(
        'reset',
        {
          'email': email.trim(),
          'token': code.trim(),
          'password': newPassword,
          'confirm_password': newPassword,
        },
        mock: () => const ApiResult(true, 'Password berhasil diubah'),
      );

  static Future<ApiResult> _post(
      String path,
      Map<String, dynamic> body, {
        required ApiResult Function() mock,
      }) async {
    try {
      // Saklar simulasi offline (long-press logo di Beranda)
      if (AppState.offline.value) throw Exception('Simulasi offline aktif');

      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 900));
        return mock();
      }

      final res = await http
          .post(
        Uri.parse('$_base/$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 45));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      final ok = res.statusCode == 200 && data['success'] != false;
      return ApiResult(
        ok,
        data['message']?.toString() ??
            (ok ? 'Berhasil' : 'Terjadi kesalahan (${res.statusCode})'),
      );
    } catch (e) {
      debugPrint('PasswordResetService error: $e');
      return const ApiResult(
        false,
        'Gagal terhubung ke server. Pastikan koneksi internet dan backend aktif.',
        networkError: true,
      );
    }
  }
}