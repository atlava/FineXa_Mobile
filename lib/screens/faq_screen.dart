import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<dynamic> _faqs = [];
  bool _isLoading = true;
  String? _errorMsg;

  final _search = TextEditingController();
  String _query = '';
  dynamic _openId;
  String? _token;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initAndFetchFaqs();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      final id = payload['id_user'];
      return id is int ? id : int.tryParse(id.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _initAndFetchFaqs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _userId = prefs.getInt('user_id') ??
        (_token != null ? _extractUserIdFromToken(_token!) : null);

    await _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/faq'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> rawData = body['data'] ?? [];

        final publishedFaqs = rawData.where((item) {
          if (item is Map) {
            return item['status'] == null || item['status'] == 'published';
          }
          return false;
        }).toList();

        setState(() {
          _faqs = publishedFaqs;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMsg = 'Sesi login berakhir. Silakan login kembali.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Gagal memuat FAQ (Kode: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Tidak dapat terhubung ke server. Pastikan backend menyala.';
        _isLoading = false;
      });
    }
  }

  Future<void> _recordFaqLog(dynamic faqId) async {
    if (faqId == null || _userId == null) return;

    try {
      await http.post(
        Uri.parse('http://10.0.2.2:5000/api/faq/log'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'faq_id': faqId,
          'user_id': _userId,
        }),
      );
    } catch (e) {
      debugPrint('Gagal mencatat log FAQ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _faqs.where((e) {
      if (e is! Map) return false;
      final pertanyaan = (e['pertanyaan'] ?? '').toString().toLowerCase();
      return pertanyaan.contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text('FAQ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 24),
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              cursorColor: AppColors.emerald,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari Pertanyaan...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.emerald),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildBody(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<dynamic> items) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emerald),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchFaqs,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Pertanyaan tidak ditemukan.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.emerald,
      onRefresh: _fetchFaqs,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final faq = items[i] as Map;
          final faqId = faq['id_faq'] ?? faq['id'];
          final itemKey = faqId ?? faq['pertanyaan'];
          final q = (faq['pertanyaan'] ?? '').toString();
          final a = (faq['jawaban'] ?? '').toString();
          final isOpen = _openId == itemKey;

          return GestureDetector(
            onTap: () {
              final willOpen = !isOpen;
              setState(() => _openId = willOpen ? itemKey : null);
              if (willOpen) {
                _recordFaqLog(faqId);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isOpen
                        ? AppColors.emerald
                        : Colors.white.withValues(alpha: 0.3)),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(q,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                        Icon(isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: Colors.white),
                      ],
                    ),
                    if (isOpen) ...[
                      const Divider(color: Colors.white54, height: 18),
                      Text(a,
                          style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}