import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class BerandaScreen extends StatelessWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const BerandaScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'JU',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JagaUang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Sabtu, 10 Oktober 2026',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainerLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondaryBorder),
                    ),
                    child: Text(
                      'Status: Aman',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    color: AppColors.onSurface,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua sistem runway dalam kondisi optimal.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seed Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      'DATA UJI AKTIF',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kondisi riil terpetakan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulasi kondisi riil diperbarui.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Gunakan contoh',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Summary Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildLedgerCard(
                    title: 'Total Aset',
                    amount: AppState.formatRupiah(state.totalAssets),
                    subtitle: 'Termasuk investasi',
                    icon: Icons.account_balance_outlined,
                    iconColor: AppColors.outline,
                    amountColor: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLedgerCard(
                    title: 'Bisa Dipakai',
                    amount: AppState.formatRupiah(state.spendableCash),
                    subtitle: 'Tersedia harian',
                    icon: Icons.savings_outlined,
                    iconColor: AppColors.secondary,
                    amountColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildLedgerCard(
                    title: 'Dana Terkunci',
                    amount: AppState.formatRupiah(state.lockedFunds),
                    subtitle: 'Stockbit (Portofolio)',
                    icon: Icons.lock_outline,
                    iconColor: AppColors.outline,
                    amountColor: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLedgerCard(
                    title: 'Kewajiban',
                    amount: AppState.formatRupiah(state.unpaidObligations),
                    subtitle: 'Gym & Keluarga',
                    icon: Icons.event_busy_outlined,
                    iconColor: AppColors.error,
                    amountColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gatekeeper Runway Guard Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 18, color: AppColors.onSurface),
                          const SizedBox(width: 6),
                          Text(
                            'Gatekeeper Runway',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${state.daysRemaining} hari tersisa',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Daily Target vs Spent
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Harian',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppState.formatRupiah(state.selectedDailyTarget)}/hari',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppColors.outlineVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengeluaran Hari Ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    AppState.formatRupiah(state.todaySpent),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(Sisa: ${AppState.formatRupiah(state.todayQuotaRemaining)})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: state.todayQuotaRemaining >= 0 ? AppColors.secondary : AppColors.error,
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
                  const SizedBox(height: 12),

                  // Ledger Projection Matrix
                  _buildProjectionRow(
                    label: 'Proyeksi Pengeluaran (${state.daysRemaining} hari × ${AppState.formatRupiah(state.selectedDailyTarget)})',
                    value: AppState.formatRupiah(state.projectedExpensePeriod),
                  ),
                  const SizedBox(height: 6),
                  _buildProjectionRow(
                    label: 'Alokasi Kewajiban Bersih',
                    value: AppState.formatRupiah(state.unpaidObligations),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.surfaceContainer),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Proyeksi Saldo Akhir Bulan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        AppState.formatRupiah(state.projectedEndBalance),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Formula Detail Action Button -> Navigate to Planning tab
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.search, size: 16, color: AppColors.onSurface),
                    label: Text(
                      'Lihat rincian perhitungan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    onPressed: () => onNavigateTab(3), // Tab 3 is Planning
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accounts & Pockets Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Akun & Kantong',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '5 SUMBER DANA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pockets Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  // Bank Jago
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'J',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bank Jago',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Multi-Pocket Akuntabel',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              AppState.formatRupiah(1159800),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Sub-pockets
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: AppColors.surfaceContainerHigh, width: 2),
                            ),
                          ),
                          child: Column(
                            children: state.pockets
                                .where((p) => p.parentAccount == 'Bank Jago')
                                .map((p) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: p.id == 'jago_makan'
                                                      ? AppColors.secondary
                                                      : AppColors.outline,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                p.name,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            AppState.formatRupiah(p.balance),
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceContainer, height: 1),

                  // Other Accounts: Tunai, BRI, Stockbit
                  ...state.pockets
                      .where((p) => p.parentAccount != 'Bank Jago')
                      .map((p) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.outlineVariant),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        p.id == 'cash'
                                            ? Icons.wallet_outlined
                                            : p.id == 'bri'
                                                ? Icons.account_balance_outlined
                                                : Icons.trending_up,
                                        size: 14,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          p.subtitle,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  AppState.formatRupiah(p.balance),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Alokasi Kewajiban Bulan Ini
            Text(
              'Alokasi Kewajiban Bulan Ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            ...state.obligations.map((o) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: o.isPaid ? AppColors.secondaryBorder : AppColors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      o.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: o.isPaid
                                            ? AppColors.secondaryContainerLight
                                            : AppColors.errorContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        o.isPaid ? 'LUNAS' : o.dueDate,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: o.isPaid
                                              ? AppColors.onSecondaryContainer
                                              : AppColors.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Sumber: ${o.sourcePocket}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppState.formatRupiah(o.amount),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.surfaceContainer, height: 1),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: o.isPaid
                                ? AppColors.secondaryContainerLight
                                : AppColors.surfaceContainerLowest,
                            side: BorderSide(
                              color: o.isPaid ? AppColors.secondary : AppColors.outline,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          icon: Icon(
                            o.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 14,
                            color: o.isPaid ? AppColors.secondary : AppColors.onSurface,
                          ),
                          label: Text(
                            o.isPaid ? 'Sudah Dibayar' : 'Tandai Sudah Dibayar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: o.isPaid ? AppColors.secondary : AppColors.onSurface,
                            ),
                          ),
                          onPressed: () => state.toggleObligationPaid(o.id),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
