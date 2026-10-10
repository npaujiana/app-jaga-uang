import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class TransaksiScreen extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const TransaksiScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Semua',
    '📤 Pengeluaran',
    '📥 Pemasukan',
    '🔁 Transfer',
    '⚙️ Penyesuaian',
    '🤝 Reimbursement',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionItem> get _filteredTransactions {
    return widget.state.transactions.where((tx) {
      if (_selectedFilter == '📤 Pengeluaran' && tx.type != 'Pengeluaran') return false;
      if (_selectedFilter == '📥 Pemasukan' && tx.type != 'Pemasukan') return false;
      if (_selectedFilter == '🔁 Transfer' && tx.type != 'Transfer') return false;
      if (_selectedFilter == '⚙️ Penyesuaian' && tx.type != 'Penyesuaian') return false;
      if (_selectedFilter == '🤝 Reimbursement' && tx.type != 'Reimburse') return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = tx.title.toLowerCase().contains(q) ||
            tx.category.toLowerCase().contains(q) ||
            tx.accountPocket.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;

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
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Text(
                      'LEDGER v2.4',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
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
            // Title & Audit Active badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 22, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Transaksi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        'AUDIT AKTIF',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search bar & Filter button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari catatan transaksi...',
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.outline, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLowest,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  icon: const Icon(Icons.tune, size: 18, color: AppColors.onSurface),
                  label: Text(
                    'Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Account Filter Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CAKUPAN AKUN',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          'Semua Rekening & Kantong',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Ganti',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Audit Notification Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Audit: Nilai asli preserved, status rekonsiliasi verified',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Integritas entri buku kas ganda terlindungi secara kriptografis lokal.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date Header 1: Sabtu, 10 Oktober 2026
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text(
                        'Sabtu, 10 Oktober 2026',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Net: -${AppState.formatRupiah(widget.state.todaySpent)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transactions List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Tidak ada transaksi yang sesuai.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const Divider(
                        color: AppColors.surfaceContainer,
                        height: 1,
                      ),
                      itemBuilder: (ctx, index) {
                        final tx = filtered[index];
                        final isExpense = tx.type == 'Pengeluaran';
                        final isIncome = tx.type == 'Pemasukan';

                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (bctx) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Audit Log Detail',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('ID Transaksi: ${tx.id}', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                                    Text('Deskripsi: ${tx.title}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                    Text('Kategori: ${tx.category}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                    Text('Sumber: ${tx.accountPocket}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                    Text('Nominal: ${AppState.formatRupiah(tx.amount)}', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('Waktu: ${tx.dateTime}', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                        onPressed: () => Navigator.pop(bctx),
                                        child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isExpense
                                        ? '📤'
                                        : isIncome
                                            ? '📥'
                                            : '⚙️',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              tx.title,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceContainer,
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: AppColors.outlineVariant),
                                            ),
                                            child: Text(
                                              tx.category,
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.account_balance, size: 12, color: AppColors.outline),
                                          const SizedBox(width: 4),
                                          Text(
                                            tx.accountPocket,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${tx.dateTime.hour.toString().padLeft(2, '0')}:${tx.dateTime.minute.toString().padLeft(2, '0')} WIB',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              color: AppColors.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isExpense ? '-' : isIncome ? '+' : ''}${AppState.formatRupiah(tx.amount)}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isExpense
                                            ? AppColors.onSurface
                                            : isIncome
                                                ? AppColors.secondary
                                                : AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Terverifikasi',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
