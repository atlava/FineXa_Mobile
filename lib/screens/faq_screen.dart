import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Jawaban selain nomor 2 masih placeholder.
  static const _faqs = <(String, String)>[
    ('Apa itu FineXa?',
        'FineXa adalah platform rekomendasi investasi berbasis profil risiko untuk investor pemula.'),
    ('Bagaimana cara mengetahui saran investasi?',
        'Akses melalui menu Saran Investasi di bottom navigation.'),
    ('Apa itu profil risiko?',
        'Profil risiko menggambarkan seberapa besar risiko yang siap Anda tanggung saat berinvestasi (konservatif, moderat, agresif).'),
    ('Memahami risiko investasi',
        'Setiap investasi memiliki risiko. Semakin tinggi potensi imbal hasil, biasanya semakin tinggi pula risikonya.'),
    ('Bagaimana perlindungan data pengguna di FineXa?',
        'Data Anda disimpan dengan aman dan hanya digunakan untuk keperluan rekomendasi investasi.'),
  ];

  final _search = TextEditingController();
  String _query = '';
  String? _open;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _faqs
        .where((e) => e.$1.toLowerCase().contains(_query.toLowerCase()))
        .toList();

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
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final (q, a) = items[i];
                  final isOpen = _open == q;
                  return GestureDetector(
                    onTap: () => setState(() => _open = isOpen ? null : q),
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
            ),
          ],
        ),
      ),
    );
  }
}
