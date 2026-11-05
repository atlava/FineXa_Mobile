import 'package:flutter/material.dart';

enum RiskType { konservatif, moderat, agresif }

/// State sederhana (sementara). Nanti bisa diganti Provider/Riverpod/Bloc.
class AppState {
  static final ValueNotifier<RiskType?> risk = ValueNotifier<RiskType?>(null);
}

class AllocItem {
  final String name;
  final int pct;
  final Color color;
  const AllocItem(this.name, this.pct, this.color);
}

class RiskInfo {
  final String label;
  final String desc;
  final String expectedReturn;
  final String horizon;
  final List<AllocItem> allocations;
  const RiskInfo({
    required this.label,
    required this.desc,
    required this.expectedReturn,
    required this.horizon,
    required this.allocations,
  });
}

class QuizOption {
  final String title;
  final String? subtitle;
  final int score;
  const QuizOption(this.title, this.score, {this.subtitle});
}

class QuizQuestion {
  final String text;
  final List<QuizOption> options;
  const QuizQuestion(this.text, this.options);
}

class RiskData {
  static const _cSaham = Color(0xFF0F4F40);
  static const _cCampuran = Color(0xFF4B7BEC);
  static const _cObligasi = Color(0xFFE0A526);
  static const _cUang = Color(0xFF9AA5A0);

  static const Map<RiskType, RiskInfo> info = {
    RiskType.konservatif: RiskInfo(
      label: 'Konservatif',
      desc: 'Mengutamakan keamanan dana',
      expectedReturn: '5 - 8% / tahun',
      horizon: '1-3 tahun',
      allocations: [
        AllocItem('Reksadana Saham', 15, _cSaham),
        AllocItem('Reksadana Campuran', 20, _cCampuran),
        AllocItem('Obligasi Pemerintah', 40, _cObligasi),
        AllocItem('Reksadana Pasar Uang', 25, _cUang),
      ],
    ),
    RiskType.moderat: RiskInfo(
      label: 'Moderat',
      desc: 'Seimbang antara pertumbuhan dan stabilitas',
      expectedReturn: '10 - 15% / tahun',
      horizon: '>5 tahun',
      allocations: [
        AllocItem('Reksadana Saham', 50, _cSaham),
        AllocItem('Reksadana Campuran', 25, _cCampuran),
        AllocItem('Obligasi Pemerintah', 15, _cObligasi),
        AllocItem('Reksadana Pasar Uang', 10, _cUang),
      ],
    ),
    RiskType.agresif: RiskInfo(
      label: 'Agresif',
      desc: 'Fokus pada pertumbuhan jangka panjang',
      expectedReturn: '15 - 25% / tahun',
      horizon: '>7 tahun',
      allocations: [
        AllocItem('Reksadana Saham', 70, _cSaham),
        AllocItem('Reksadana Campuran', 15, _cCampuran),
        AllocItem('Obligasi Pemerintah', 10, _cObligasi),
        AllocItem('Reksadana Pasar Uang', 5, _cUang),
      ],
    ),
  };

  static RiskType classify(int totalScore) {
    if (totalScore <= 8) return RiskType.konservatif;
    if (totalScore <= 11) return RiskType.moderat;
    return RiskType.agresif;
  }

  // Pertanyaan 1 dari PDF. Pertanyaan 2-5 masih placeholder,
  // ganti nanti sesuai screenshot kuesioner yang asli.
  static const List<QuizQuestion> questions = [
    QuizQuestion(
      'Bagaimana Anda mendeskripsikan tingkat pengetahuan dan pengalaman Anda dalam berinvestasi saat ini?',
      [
        QuizOption('Saya pemula murni', 1,
            subtitle: 'Pengalaman saya sebatas menabung di bank atau deposito konvesional'),
        QuizOption('Saya paham konsep dasar', 2,
            subtitle:
                'Memiliki pengalaman 1-3 tahun di instrumen berisiko rendah-menengah (seperti SBN, Emas, atau Reksa Dana Pasar Uang/Pendapatan Tetap)'),
        QuizOption('Saya sangat berpengalaman (>3 tahun)', 3,
            subtitle:
                'Aktif menganalisis instrumen volatil secara mandiri (Saham, Crypto, atau Reksa Dana Saham)'),
      ],
    ),
    QuizQuestion('Apa tujuan utama investasi Anda?', [
      QuizOption('Menjaga nilai uang', 1),
      QuizOption('Pertumbuhan yang seimbang', 2),
      QuizOption('Keuntungan semaksimal mungkin', 3),
    ]),
    QuizQuestion('Berapa lama Anda berencana berinvestasi?', [
      QuizOption('Kurang dari 1 tahun', 1),
      QuizOption('1 - 5 tahun', 2),
      QuizOption('Lebih dari 5 tahun', 3),
    ]),
    QuizQuestion('Jika nilai investasi Anda turun 20%, apa yang akan Anda lakukan?', [
      QuizOption('Jual semua agar tidak rugi lebih banyak', 1),
      QuizOption('Tahan dan tunggu pulih', 2),
      QuizOption('Tambah investasi karena harga sedang murah', 3),
    ]),
    QuizQuestion('Berapa persen pendapatan yang siap Anda investasikan?', [
      QuizOption('Kurang dari 10%', 1),
      QuizOption('10% - 30%', 2),
      QuizOption('Lebih dari 30%', 3),
    ]),
  ];
}
