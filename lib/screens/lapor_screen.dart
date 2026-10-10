import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LaporScreen extends StatefulWidget {
  final AppState state;
  final Function(int) onNavigateTab;

  const LaporScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  final TextEditingController _aiController = TextEditingController(
    text: 'Beli ketoprak 16 ribu pakai Jago kantong makan',
  );
  final TextEditingController _amountController = TextEditingController(text: '16000');
  final TextEditingController _descController = TextEditingController(text: 'Ketoprak telor siang');

  String _selectedType = 'Pengeluaran';
  String _selectedCategory = 'Makanan';
  String _selectedPocketId = 'jago_makan';
  bool _splitBill = false;

  final List<String> _types = [
    'Pengeluaran',
    'Pemasukan',
    'Transfer',
    'Penyesuaian',
    'Reimburse',
  ];

  final List<String> _categories = [
    'Makanan',
    'Jajan',
    'Kebutuhan',
    'Transportasi',
    'Keluarga',
    'Gym',
    'Skincare',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _aiController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _parseAiInput() async {
    final rawText = _aiController.text.trim();
    if (rawText.isEmpty) return;

    final res = await ApiService.parseWithRouter(
      endpoint: widget.state.aiEndpoint,
      apiKey: widget.state.aiApiKey,
      model: widget.state.aiSelectedModel,
      text: rawText,
    );

    if (res != null) {
      setState(() {
        _amountController.text = (res['amount'] as num).toInt().toString();
        _descController.text = res['description'] ?? rawText;
        _selectedCategory = res['category'] ?? 'Makanan';
        _selectedPocketId = res['pocketId'] ?? 'jago_makan';
        _selectedType = res['type'] ?? 'Pengeluaran';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Draf transaksi diuraikan oleh ${widget.state.aiSelectedModel}!'),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final text = _aiController.text.toLowerCase();
    double parsedAmount = 16000;
    String parsedDesc = _aiController.text;
    String parsedCat = 'Makanan';
    String parsedPocket = 'jago_makan';

    if (text.contains('kopi') || text.contains('jajan') || text.contains('boba')) {
      parsedCat = 'Jajan';
    } else if (text.contains('bensin') || text.contains('gojek') || text.contains('grab')) {
      parsedCat = 'Transportasi';
    } else if (text.contains('gym')) {
      parsedCat = 'Gym';
    } else if (text.contains('skincare')) {
      parsedCat = 'Skincare';
    }

    if (text.contains('tunai') || text.contains('cash') || text.contains('dompet')) {
      parsedPocket = 'cash';
    } else if (text.contains('bri')) {
      parsedPocket = 'bri';
    }

    final matchRibu = RegExp(r'(\d+)\s*(ribu|rb|k)').firstMatch(text);
    if (matchRibu != null) {
      parsedAmount = (double.tryParse(matchRibu.group(1) ?? '16') ?? 16) * 1000;
    }

    setState(() {
      _amountController.text = parsedAmount.toInt().toString();
      _descController.text = parsedDesc;
      _selectedCategory = parsedCat;
      _selectedPocketId = parsedPocket;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Draf transaksi berhasil diuraikan oleh AI Parser!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitTransaction() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }

    widget.state.addTransaction(
      title: _descController.text.trim().isEmpty ? 'Transaksi Baru' : _descController.text.trim(),
      category: _selectedCategory,
      pocketId: _selectedPocketId,
      amount: amount,
      type: _selectedType,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil mencatat transaksi ${AppState.formatRupiah(amount)}!'),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onNavigateTab(2); // Go to transaction history tab
  }

  @override
  Widget build(BuildContext context) {
    final currentAmount = double.tryParse(_amountController.text) ?? 0;
    final simulatedTodayQuota = widget.state.selectedDailyTarget - (widget.state.todaySpent + currentAmount);
    final isOverBudget = simulatedTodayQuota < 0;

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 22),
                    color: AppColors.onSurface,
                    onPressed: () => widget.onNavigateTab(0),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lapor Transaksi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Buku Kas Utama',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Panduan Lapor Transaksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                          content: const Text(
                            'Ketik kalimat pengeluaran Anda dengan santai, atau isi formulir di bawah secara manual.\n\nContoh:\n"Beli ayam geprek 20 ribu pakai cash"',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Mengerti'),
                            ),
                          ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bento Item 1: Natural Language AI Parsing Card
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
                          const Text('⚡', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Lapor Cepat Bahasa Alami',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.surfaceContainerLowest,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (ctx) => StatefulBuilder(
                              builder: (ctx, setSheetState) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pilih Model AI (9Router)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        IconButton(
                                          icon: widget.state.isAiLoadingModels
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : const Icon(Icons.refresh, size: 20),
                                          onPressed: () async {
                                            setSheetState(() {});
                                            await widget.state.refreshAiModels();
                                            setSheetState(() {});
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ...widget.state.aiAvailableModels.map((m) {
                                      final isSelected = widget.state.aiSelectedModel == m;
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          m,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                                            : null,
                                        onTap: () {
                                          widget.state.updateAiConfig(selectedModel: m);
                                          Navigator.pop(ctx);
                                          setState(() {});
                                        },
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.settings, size: 16),
                                      label: const Text('Buka Pengaturan Router & API Key'),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        widget.onNavigateTab(4);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 12, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                widget.state.aiSelectedModel,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.secondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _aiController,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      hintText: 'Contoh: Beli ketoprak 16 ribu pakai Jago kantong makan',
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.outline, fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.onSurface),
                    label: Text(
                      'Proses Draf Transaksi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    onPressed: _parseAiInput,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Confirmation Draft Alert Box
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
                  // Draft Notice Banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.task_alt, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konfirmasi Draf',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                'Periksa sebelum menyimpan ke buku kas',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainerLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.secondaryBorder),
                          ),
                          child: Text(
                            'TERDETEKSI',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Transaction Type Selector
                  Text(
                    'JENIS TRANSAKSI',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: _types.map((type) {
                        final isSelected = _selectedType == type;
                        return Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected ? Border.all(color: AppColors.outlineVariant) : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Amount (IDR) & Quick Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JUMLAH (IDR)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'NOMINAL TUNAI / DEBIT',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        child: Text(
                          'Rp',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Add Chips
                  Row(
                    children: [5000, 10000, 20000, 50000].map((addVal) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () {
                              final current = double.tryParse(_amountController.text) ?? 0;
                              setState(() {
                                _amountController.text = (current + addVal).toInt().toString();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+${addVal ~/ 1000}rb',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Deskripsi
                  Text(
                    'DESKRIPSI',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kategori & Rekening Bento Row
                  Row(
                    children: [
                      // Kategori Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KATEGORI',
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
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  icon: const Icon(Icons.expand_more, size: 18),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.onSurface,
                                  ),
                                  items: _categories.map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Rekening & Kantong Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REKENING & KANTONG',
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
                                  value: _selectedPocketId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.swap_horiz, size: 18),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onSurface,
                                  ),
                                  items: widget.state.pockets.map((p) {
                                    return DropdownMenuItem(
                                      value: p.id,
                                      child: Text(
                                        '${p.parentAccount} > ${p.name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedPocketId = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tanggal & Waktu
                  Text(
                    'TANGGAL & WAKTU',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              '10 Okt 2026, 12:45 WIB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(
                            'HARI INI',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Split Bill Toggle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.call_split, size: 20, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bagi tagihan (Split Bill)?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Pecah biaya ke beberapa orang rekan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _splitBill,
                          activeTrackColor: AppColors.secondary,
                          onChanged: (val) => setState(() => _splitBill = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gatekeeper Simulation Warning Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOverBudget ? AppColors.alertBg : AppColors.secondaryContainerLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOverBudget ? AppColors.alertBorder : AppColors.secondaryBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isOverBudget ? Icons.warning_rounded : Icons.check_circle_rounded,
                              size: 16,
                              color: isOverBudget ? AppColors.alertText : AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Simulasi Kuota Pengeluaran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isOverBudget ? AppColors.alertText : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOverBudget
                              ? 'Sisa kuota harian setelah transaksi ini: -Rp${(-simulatedTodayQuota).toInt()} (Over target, proyeksi saldo akhir turun jadi ${AppState.formatRupiah(widget.state.projectedEndBalance - currentAmount)})'
                              : 'Sisa kuota harian setelah transaksi ini: Rp${simulatedTodayQuota.toInt()} (Aman di bawah target harian ${AppState.formatRupiah(widget.state.selectedDailyTarget)})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isOverBudget ? AppColors.alertDark : AppColors.onSecondaryContainer,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit CTA
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      'Simpan Transaksi (${AppState.formatRupiah(currentAmount)})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _submitTransaction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
