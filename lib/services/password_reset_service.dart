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

/// Layanan lupa password: kirim kode -> verifikasi kode -> password baru.
class PasswordResetService {
  /// true  = data pura-pura (tanpa backend), kode yang benar = [mockCode].
  /// false = pakai endpoint backend asli (lihat 3 endpoint di bawah).
  /// Ubah ke false setelah endpoint backend siap.
  static const bool useMock = true;
  static const String mockCode = '123456';

  static const String _base = 'http://10.0.2.2:5000/api/auth';

  /// POST /api/auth/forgot-password        body: {email}
  static Future<ApiResult> sendCode(String email) => _post(
        'forgot-password',
        {'email': email},
        mock: () => const ApiResult(true, 'Kode verifikasi dikirim'),
      );

  /// POST /api/auth/verify-reset-code      body: {email, code}
  static Future<ApiResult> verifyCode(String email, String code) => _post(
        'verify-reset-code',
        {'email': email, 'code': code},
        mock: () => code == mockCode
            ? const ApiResult(true, 'Kode benar')
            : const ApiResult(false, 'Kode salah atau sudah kedaluwarsa.'),
      );

  /// POST /api/auth/reset-password         body: {email, code, new_password}
  static Future<ApiResult> resetPassword(String email, String code, String newPassword) =>
      _post(
        'reset-password',
        {'email': email, 'code': code, 'new_password': newPassword},
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
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      final ok = res.statusCode == 200 && data['success'] != false;
      return ApiResult(
        ok,
        data['message']?.toString() ?? (ok ? 'Berhasil' : 'Terjadi kesalahan (${res.statusCode})'),
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
