import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class PengaturanScreen extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const PengaturanScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String _selectedAccount = 'Bank BRI';
  final TextEditingController _actualBalanceController = TextEditingController(text: '600000');
  final TextEditingController _reasonController = TextEditingController(
    text: 'Koreksi saldo fisik / bunga tabungan',
  );
  late TextEditingController _aiEndpointController;
  late TextEditingController _aiApiKeyController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _aiEndpointController = TextEditingController(text: widget.state.aiEndpoint);
    _aiApiKeyController = TextEditingController(text: widget.state.aiApiKey);
  }

  @override
  void dispose() {
    _actualBalanceController.dispose();
    _reasonController.dispose();
    _aiEndpointController.dispose();
    _aiApiKeyController.dispose();
    super.dispose();
  }

  void _handleReconciliation() {
    final actual = double.tryParse(_actualBalanceController.text) ?? 0;
    if (actual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal saldo nyata yang valid.')),
      );
      return;
    }

    widget.state.reconcileAccount(
      accountName: _selectedAccount,
      actualBalance: actual,
      reason: _reasonController.text.trim().isEmpty
          ? 'Penyesuaian saldo berkala'
          : _reasonController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rekonsiliasi $_selectedAccount berhasil dicatat ke Audit Trail!'),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onNavigateTab(2); // Go to transaction history to see audit entry
  }

  @override
  Widget build(BuildContext context) {
    final briPocket = widget.state.pockets.firstWhere(
      (p) => p.name.contains('BRI') || p.parentAccount.contains('BRI'),
      orElse: () => widget.state.pockets.first,
    );
    final appBalance = briPocket.balance;
    final actualVal = double.tryParse(_actualBalanceController.text) ?? appBalance;
    final diff = actualVal - appBalance;

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
            // Screen Header Title
            Row(
              children: [
                const Icon(Icons.tune, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'SISTEM BUKU KAS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pengaturan & Rekonsiliasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Integritas Buku Kas & Audit Data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Rekonsiliasi Saldo Riil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.balance, size: 18, color: AppColors.onSurface),
                    const SizedBox(width: 6),
                    Text(
                      'Rekonsiliasi Saldo Riil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Text(
                    'AUDIT HARIAN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

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
                      Text(
                        'Cek & Sesuaikan Saldo',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Icon(Icons.verified, size: 18, color: AppColors.outlineVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Menyesuaikan saldo aplikasi dengan saldo rekening riil tanpa merusak riwayat transaksi terdahulu.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.outlineVariant),
                  ),

                  // Rekening Selector
                  Text(
                    'SELECTOR REKENING',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedAccount,
                        isExpanded: true,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurface),
                        items: const [
                          DropdownMenuItem(value: 'Bank BRI', child: Text('Bank BRI')),
                          DropdownMenuItem(value: 'Bank Jago', child: Text('Bank Jago')),
                          DropdownMenuItem(value: 'Dompet Tunai', child: Text('Kas Tunai (Dompet Fisik)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAccount = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metric Comparison Grid
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo di Aplikasi',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppState.formatRupiah(appBalance),
                                style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Sesuai buku kas',
                                style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.outlineVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selisih Terhitung',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${diff >= 0 ? '+' : ''}${AppState.formatRupiah(diff)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: diff >= 0 ? AppColors.secondary : AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: diff >= 0 ? AppColors.secondaryContainerLight : AppColors.errorContainer,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      diff >= 0 ? 'Surplus' : 'Defisit',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: diff >= 0 ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Kredit penyeimbang',
                                style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Saldo Nyata
                  Text(
                    'INPUT SALDO NYATA (MUTASI FISIK)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _actualBalanceController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        child: Text(
                          'Rp',
                          style: GoogleFonts.jetBrainsMono(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                  const SizedBox(height: 12),

                  // Field Alasan Penyesuaian
                  Text(
                    'ALASAN PENYESUAIAN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
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
                  const SizedBox(height: 16),

                  // Submit CTA
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.post_add, size: 18),
                    label: Text(
                      'Simpan Penyesuaian & Buat Audit Log',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _handleReconciliation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Kelola Rekening & Floor Proteksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.onSurface),
                    const SizedBox(width: 6),
                    Text(
                      'Kelola Rekening & Floor Proteksi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  '2 REKENING TERDAFTAR',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  // Item 1: Bank BRI
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  child: const Icon(Icons.account_balance, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bank BRI',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'OPERASIONAL UTAMA',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: Text(
                                'AKTIF',
                                style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
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
                                    'Floor Proteksi Saldo:',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.outlineVariant),
                                    ),
                                    child: Text(
                                      AppState.formatRupiah(widget.state.protectedFloorBRI),
                                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dana di bawah nilai ini tidak dihitung spendable (dicadangkan otomatis).',
                                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceContainer, height: 1),

                  // Item 2: Stockbit
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: const Icon(Icons.trending_up, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stockbit',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'INVESTASI / PORTOFOLIO',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TERKUNCI',
                            style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: AI & 9Router Gateway Configuration
            Row(
              children: [
                const Icon(Icons.psychology, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'INTEGRASI AI & 9ROUTER',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                          const Text('🤖', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Router AI Gateway',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.state.aiAvailableModels.isNotEmpty
                              ? AppColors.secondary.withValues(alpha: 0.12)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: widget.state.aiAvailableModels.isNotEmpty
                                ? AppColors.secondary
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            widget.state.aiSelectedModel,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: widget.state.aiAvailableModels.isNotEmpty
                                  ? AppColors.secondary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Endpoint Input
                  Text(
                    'Router Endpoint URL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _aiEndpointController,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      hintText: 'https://9router.npaujiana.tech/v1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (val) => widget.state.updateAiConfig(endpoint: val),
                  ),
                  const SizedBox(height: 10),
                  // API Key Input
                  Text(
                    'API Key / Token (Bearer)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _aiApiKeyController,
                    obscureText: _obscureApiKey,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      hintText: 'Masukkan API Key 9Router Anda...',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (val) => widget.state.updateAiConfig(apiKey: val),
                  ),
                  const SizedBox(height: 12),
                  // Model Selector Dropdown & Refresh Button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Model Aktif',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: widget.state.aiAvailableModels.contains(widget.state.aiSelectedModel)
                                      ? widget.state.aiSelectedModel
                                      : (widget.state.aiAvailableModels.isNotEmpty
                                          ? widget.state.aiAvailableModels.first
                                          : null),
                                  items: widget.state.aiAvailableModels.map((m) {
                                    return DropdownMenuItem<String>(
                                      value: m,
                                      child: Text(
                                        m,
                                        style: GoogleFonts.jetBrainsMono(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      widget.state.updateAiConfig(selectedModel: val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onPressed: widget.state.isAiLoadingModels
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final res = await widget.state.refreshAiModels();
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        res.isSuccess
                                            ? '✅ Berhasil memuat ${res.models.length} model dari 9Router!'
                                            : '⚠️ ${res.errorMessage ?? "Gagal memuat model"}',
                                      ),
                                      backgroundColor: res.isSuccess ? AppColors.secondary : Colors.orange[800],
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                          icon: widget.state.isAiLoadingModels
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                            widget.state.isAiLoadingModels ? 'Memuat...' : 'Refresh',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.state.aiLastRefreshStatus != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.state.aiLastRefreshStatus!.startsWith('Berhasil')
                            ? AppColors.secondary.withValues(alpha: 0.08)
                            : Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.state.aiLastRefreshStatus!.startsWith('Berhasil')
                              ? AppColors.secondary.withValues(alpha: 0.3)
                              : Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.state.aiLastRefreshStatus!.startsWith('Berhasil')
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 14,
                            color: widget.state.aiLastRefreshStatus!.startsWith('Berhasil')
                                ? AppColors.secondary
                                : Colors.orange[800],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.state.aiLastRefreshStatus!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: widget.state.aiLastRefreshStatus!.startsWith('Berhasil')
                                    ? AppColors.secondary
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
