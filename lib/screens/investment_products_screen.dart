import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/error_widgets.dart';

class InvestmentProductsScreen extends StatefulWidget {
  const InvestmentProductsScreen({super.key});

  @override
  State<InvestmentProductsScreen> createState() =>
      _InvestmentProductsScreenState();
}

class _InvestmentProductsScreenState extends State<InvestmentProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (AppState.offline.value) {
        throw Exception('Mode offline aktif');
      }

      final url = Uri.parse('https://befinexaexpress-production.up.railway.app/api/assets');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _products = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat produk (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch assets: $e');
      setState(() {
        _errorMessage = 'Koneksi ke server terputus. Periksa jaringan Anda.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskType = AppState.risk.value;
    final riskLabel =
    riskType != null ? RiskData.info[riskType]?.label ?? 'Moderat' : 'Semua Profil';

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.white),
            ),
          ),
        ),
        title: const Text(
          'Produk Investasi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.emerald),
        )
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchAssets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.textDark,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchAssets,
          color: AppColors.emerald,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: _products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rekomendasi Investasi Anda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          children: [
                            const TextSpan(
                                text: 'berdasarkan profil risiko '),
                            TextSpan(
                              text: riskLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final item = _products[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(
                  namaAset: item['nama_aset'] ?? '-',
                  deskripsi: item['deskripsi'] ?? '-',
                  tingkatRisiko: item['tingkat_risiko'] ?? '-',
                  estimasiReturn: item['estimasi_return'] ?? '-',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String namaAset;
  final String deskripsi;
  final String tingkatRisiko;
  final String estimasiReturn;

  const _ProductCard({
    required this.namaAset,
    required this.deskripsi,
    required this.tingkatRisiko,
    required this.estimasiReturn,
  });

  @override
  Widget build(BuildContext context) {
    return LightCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaAset,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            deskripsi,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDark.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: AppColors.textDark.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risiko:',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tingkatRisiko,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Return:',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    estimasiReturn,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1FA84F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}