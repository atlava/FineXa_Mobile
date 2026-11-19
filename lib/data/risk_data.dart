import 'package:flutter/material.dart';

// 1. Enum Tipe Risiko yang dibutuhkan HomeScreen & ProfileScreen
enum RiskType { konservatif, moderat, agresif }

// 2. State Global untuk Menyimpan Status Risiko User
class AppState {
  static final ValueNotifier<RiskType?> risk = ValueNotifier<RiskType?>(null);

  /// Simulasi koneksi putus / server error (untuk demo error state).
  /// Tahan lama (long-press) logo di header Beranda untuk ON/OFF.
  static final ValueNotifier<bool> offline = ValueNotifier<bool>(false);
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

  // 3. Peta Informasi Risiko yang dibutuhkan HomeScreen & ProfileScreen
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

  // 5 Pilar Pertanyaan Kuesioner Profesional
  static const List<QuizQuestion> questions = [
    QuizQuestion(
      'Bagaimana Anda mendeskripsikan tingkat pengetahuan dan pengalaman Anda dalam berinvestasi saat ini?',
      [
        QuizOption('Pemula murni', 1, subtitle: 'Pengalaman saya sebatas menabung di bank atau deposito konvensional.'),
        QuizOption('Paham konsep dasar', 2, subtitle: 'Memiliki pengalaman 1-3 tahun di instrumen berisiko rendah-menengah.'),
        QuizOption('Sangat berpengalaman (>3 tahun)', 3, subtitle: 'Aktif menganalisis instrumen volatil secara mandiri (Saham, Crypto, dll).'),
      ],
    ),
    QuizQuestion(
      'Bagaimana kondisi dana darurat dan porsi tabungan bulanan Anda saat ini?',
      [
        QuizOption('Kurang dari 3 bulan / <10%', 1, subtitle: 'Dana darurat <3 bulan pengeluaran, menyisihkan <10% pendapatan.'),
        QuizOption('Aman 3-6 bulan / 10%-20%', 2, subtitle: 'Dana darurat aman 3-6 bulan, rutin menyisihkan 10% - 20% pendapatan.'),
        QuizOption('Sangat kuat (>6 bulan) / >20%', 3, subtitle: 'Dana darurat >6 bulan pengeluaran, leluasa menggunakan >20% sebagai uang dingin.'),
      ],
    ),
    QuizQuestion(
      'Bagaimana beban cicilan hutang bulanan terhadap pendapatan Anda?',
      [
        QuizOption('Berat (>35% pendapatan)', 1, subtitle: 'Total cicilan menyita lebih dari 35% pendapatan bulanan.'),
        QuizOption('Terkendali (15% - 35%)', 2, subtitle: 'Porsi cicilan berada di batas wajar 15% hingga 35%.'),
        QuizOption('Sangat sehat (Bebas / <15%)', 3, subtitle: 'Bebas hutang konsumtif atau cicilan di bawah 15%.'),
      ],
    ),
    QuizQuestion(
      'Bagaimana reaksi mental Anda jika nilai portofolio investasi mengalami penurunan (minus)?',
      [
        QuizOption('Panik / Minus 5% cemas', 1, subtitle: 'Keamanan modal mutlak. Minus 5% saja membuat cemas dan ingin mencairkan.'),
        QuizOption('Fluktuasi menengah (10-15%)', 2, subtitle: 'Siap menghadapi fluktuasi menengah 10-15% sambil evaluasi pasar.'),
        QuizOption('Pertumbuhan agresif (>20%)', 3, subtitle: 'Penurunan >20% dianggap peluang emas untuk average down.'),
      ],
    ),
    QuizQuestion(
      'Berapa lama perkiraan waktu terdekat hingga Anda berencana mencairkan dan menggunakan dana investasi ini?',
      [
        QuizOption('Sangat likuid (<1 tahun)', 1, subtitle: 'Perlu mencairkan dana dalam waktu <1 tahun untuk kebutuhan pasti.'),
        QuizOption('Jangka menengah (1 - 5 tahun)', 2, subtitle: 'Dana dipersiapkan untuk target finansial 1 hingga 5 tahun ke depan.'),
        QuizOption('Jangka panjang (>5 tahun)', 3, subtitle: 'Didedikasikan untuk pertumbuhan jangka panjang (>5 tahun) tanpa disentuh.'),
      ],
    ),
  ];
}