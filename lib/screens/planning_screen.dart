import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class PlanningScreen extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const PlanningScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  double _customSliderVal = 15000;

  @override
  void initState() {
    super.initState();
    _customSliderVal = widget.state.selectedDailyTarget;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'JU',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'JagaUang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    color: AppColors.onSurface,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RUNWAY AKTIF',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${state.daysRemaining} Hari Tersisa',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Header Title
            Text(
              'Planning & Runway',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Simulasi Proyeksi Akhir Bulan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Rumus Kalkulasi Runway Aktif Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calculate_outlined, size: 18, color: AppColors.onSurface),
                          const SizedBox(width: 6),
                          Text(
                            'Rumus Kalkulasi Runway Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Ledger #402',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Formula Matrix
                  _buildFormulaRow('Spendable Cash', AppState.formatRupiah(state.spendableCash)),
                  const SizedBox(height: 4),
                  _buildFormulaRow('− Protected BRI Floor', AppState.formatRupiah(state.protectedFloorBRI), isDim: true),
                  const SizedBox(height: 4),
                  _buildFormulaRow('− Obligasi Belum Dibayar', AppState.formatRupiah(state.unpaidObligations), isDim: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.surfaceContainer),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USABLE MONEY',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Dana bersih siap dialokasikan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppState.formatRupiah(state.usableMoney),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Metric Blocks Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surfaceContainer),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SISA HARI',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.daysRemaining} hari kalender',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                '(termasuk hari ini)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surfaceContainer),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BREAK-EVEN MAX',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppState.formatRupiah(state.breakEvenDailyRate)}/hari',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                'Batas aman teoretis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skenario Anggaran Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '4 Skenario Anggaran Harian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'PILIH TARGET',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4 Scenarios List
            ...state.scenarios.map((sc) {
              final isCurrent = state.selectedDailyTarget == sc.amount;
              final expensePeriod = state.daysRemaining * sc.amount;
              final projectedEnd = state.spendableCash - expensePeriod - state.unpaidObligations;

              return InkWell(
                onTap: () {
                  state.setDailyTarget(sc.amount);
                  setState(() => _customSliderVal = sc.amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Target harian diubah ke ${AppState.formatRupiah(sc.amount)}/hari'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : AppColors.outlineVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isCurrent) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'AKTIF',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sc.badgeText == 'Aman'
                                      ? AppColors.secondaryContainerLight
                                      : sc.badgeText == 'Waspada'
                                          ? const Color(0xFFFEF9C3)
                                          : AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  sc.badgeText,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: sc.badgeText == 'Aman'
                                        ? AppColors.onSecondaryContainer
                                        : sc.badgeText == 'Waspada'
                                            ? const Color(0xFF854D0E)
                                            : AppColors.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isCurrent)
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sc.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Breakdown
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proyeksi Belanja (${state.daysRemaining} hari)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  AppState.formatRupiah(expensePeriod),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proyeksi Saldo Akhir',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  AppState.formatRupiah(projectedEnd),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: projectedEnd >= 0 ? AppColors.secondary : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Interactive Simulator Slider
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Simulasi Bebas Target Harian',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Geser untuk melihat dampak saldo akhir:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Slider(
                    value: _customSliderVal,
                    min: 5000,
                    max: 80000,
                    divisions: 15,
                    activeColor: AppColors.primary,
                    label: AppState.formatRupiah(_customSliderVal),
                    onChanged: (val) {
                      setState(() => _customSliderVal = val);
                      state.setDailyTarget(val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target: ${AppState.formatRupiah(_customSliderVal)}/hari',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Saldo Akhir: ${AppState.formatRupiah(state.projectedEndBalance)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: state.projectedEndBalance >= 0 ? AppColors.secondary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaRow(String label, String value, {bool isDim = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isDim ? AppColors.outline : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDim ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
