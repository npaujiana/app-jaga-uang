import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'screens/beranda_screen.dart';
import 'screens/lapor_screen.dart';
import 'screens/transaksi_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/pengaturan_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JagaUangApp());
}

class JagaUangApp extends StatefulWidget {
  const JagaUangApp({super.key});

  @override
  State<JagaUangApp> createState() => _JagaUangAppState();
}

class _JagaUangAppState extends State<JagaUangApp> {
  final AppState _state = AppState();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _state.syncFromBackend();
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JagaUang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          final screens = [
            BerandaScreen(state: _state, onNavigateTab: _onNavigateTab),
            LaporScreen(state: _state, onNavigateTab: _onNavigateTab),
            TransaksiScreen(state: _state, onNavigateTab: _onNavigateTab),
            PlanningScreen(state: _state, onNavigateTab: _onNavigateTab),
            PengaturanScreen(state: _state, onNavigateTab: _onNavigateTab),
          ];

          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, 'Beranda', Icons.dashboard_outlined, Icons.dashboard),
                      _buildNavItem(1, 'Lapor', Icons.add_circle_outline, Icons.add_circle),
                      _buildNavItem(2, 'Transaksi', Icons.receipt_long_outlined, Icons.receipt_long),
                      _buildNavItem(3, 'Planning', Icons.pie_chart_outline, Icons.pie_chart),
                      _buildNavItem(4, 'Pengaturan', Icons.settings_outlined, Icons.settings),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigateTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
