import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'questionnaire_screen.dart';

class MainShell extends StatefulWidget {
  // 1. Tambahkan variabel userId di sini
  final String userId;

  // 2. Jadikan parameter ini wajib diisi saat MainShell dipanggil
  const MainShell({super.key, required this.userId});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _onTap(int i) {
    if (i == 1) {
      // Tab "Saran" membuka kuesioner sebagai halaman terpisah
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const QuestionnaireScreen()));
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onGoToFaq: () => setState(() => _index = 2),
        // 3. Teruskan userId yang didapat ke HomeScreen
        userId: widget.userId,
      ),
      const SizedBox.shrink(),
      const FaqScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            IndexedStack(index: _index, children: pages),
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BottomNav(index: _index, onTap: _onTap),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, 'Beranda'),
    (Icons.pie_chart_outline, 'Saran'),
    (Icons.help_outline, 'FAQ'),
    (Icons.account_circle_outlined, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF14574A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == index;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_items[i].$1,
                      size: 20, color: selected ? AppColors.textDark : Colors.white),
                  const SizedBox(height: 2),
                  Text(_items[i].$2,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.textDark : Colors.white)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}