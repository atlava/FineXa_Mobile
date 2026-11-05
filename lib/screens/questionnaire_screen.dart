import 'package:flutter/material.dart';
import '../data/risk_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _questions = RiskData.questions;
  final List<int> _scores = [];
  int _step = 0;
  int? _selected;
  bool _locked = false;

  void _choose(int i) {
    if (_locked) return;
    setState(() {
      _selected = i;
      _locked = true;
    });
    // Auto-advance (Hick's Law)
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _scores.add(_questions[_step].options[i].score);
      if (_step == _questions.length - 1) {
        final total = _scores.fold<int>(0, (a, b) => a + b);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(type: RiskData.classify(total))),
        );
      } else {
        setState(() {
          _step++;
          _selected = null;
          _locked = false;
        });
      }
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        _step--;
        _scores.removeLast();
        _selected = null;
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_step];
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text('Saran Investasi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 24),
                _Stepper(current: _step, total: _questions.length),
                const SizedBox(height: 36),
                Text(q.text,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: q.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OptionTile(
                      option: q.options[i],
                      selected: _selected == i,
                      onTap: () => _choose(i),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _back,
                  child: const Text('Kembali',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int current;
  final int total;
  const _Stepper({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < total; i++) {
      final active = i <= current;
      children.add(Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.emerald : Colors.white.withValues(alpha: 0.25),
        ),
        child: Text('${i + 1}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.textDark : Colors.white)),
      ));
      if (i < total - 1) {
        children.add(Container(
            width: 10, height: 1.5, color: Colors.white.withValues(alpha: 0.5)));
      }
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}

class _OptionTile extends StatelessWidget {
  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: selected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.emerald : Colors.white.withValues(alpha: 0.25),
              width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 20, color: selected ? AppColors.emerald : Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(option.subtitle!,
                        style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
