// lib/features/analysis/pages/analysis_menu_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/monthly_section.dart';
import '../widgets/seven_days_section.dart';
import '../../../shared/widgets/tab_chip.dart';

class AnalysisMenuPage extends StatefulWidget {
  const AnalysisMenuPage({super.key});

  @override
  State<AnalysisMenuPage> createState() => _AnalysisMenuPageState();
}

class _AnalysisMenuPageState extends State<AnalysisMenuPage> {
  int _tab = 0; // 0 = 7 hari, 1 = bulanan
  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleMonth = DateFormat('MMMM yyyy', 'id_ID').format(_month);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Hasil Analisis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFF1E7A3F),
        foregroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: Column(
        children: [
          // Header Section dengan gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E7A3F),
                  Color(0xFF1E7A3F),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Tab Pills dengan modern design
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModernTab(
                            active: _tab == 0,
                            label: '7 Hari Terakhir',
                            icon: Icons.calendar_view_week_rounded,
                            onTap: () => setState(() => _tab = 0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildModernTab(
                            active: _tab == 1,
                            label: 'Bulanan',
                            icon: Icons.calendar_month_rounded,
                            onTap: () => setState(() => _tab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Content dengan transisi mulus
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _tab == 0
                  ? const SevenDaysSection(key: ValueKey('seven_days'))
                  : MonthlySection(
                      key: const ValueKey('monthly'),
                      month: _month,
                      title: titleMonth,
                      onPrev: _prevMonth,
                      onNext: _nextMonth,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTab({
    required bool active,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? const Color(0xFF1E7A3F)
                    : Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active
                        ? const Color(0xFF1E7A3F)
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
