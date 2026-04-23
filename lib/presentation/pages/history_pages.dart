import 'package:flutter/material.dart';
import 'app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Masuk', 'Keluar', 'Transfer'];

  // ── Dummy data riwayat transaksi IPAL ──────────────────────────────────────
  final List<Map<String, dynamic>> _history = [
    {
      'type': 'masuk',
      'item': 'Pompa Submersible 1 HP',
      'code': 'TRX-2026042022',
      'qty': 8,
      'unit': 'unit',
      'date': '20 Apr 2026',
      'time': '10:32',
      'by': 'Ahmad Fauzi',
      'warehouse': 'Gudang IPAL · Rak A-03',
      'notes': 'Pengiriman dari vendor PT. Aquatech Mandiri',
    },
    {
      'type': 'keluar',
      'item': 'Filter Cartridge 10" 5µm',
      'code': 'TRX-2026042021',
      'qty': 24,
      'unit': 'unit',
      'date': '20 Apr 2026',
      'time': '09:15',
      'by': 'Siti Rahayu',
      'warehouse': 'Gudang IPAL · Rak B-07',
      'notes': 'Penggantian rutin filter unit IPAL Plant 02',
    },
    {
      'type': 'transfer',
      'item': 'Blower Roots 1 HP',
      'code': 'TRF-2026042020',
      'qty': 2,
      'unit': 'unit',
      'date': '20 Apr 2026',
      'time': '08:00',
      'by': 'Rudi Hermawan',
      'warehouse': 'Gudang IPAL A → Gudang IPAL C',
      'notes': 'Transfer untuk perawatan unit aerasi',
    },
    {
      'type': 'masuk',
      'item': 'Membran RO 4040',
      'code': 'TRX-2026041919',
      'qty': 12,
      'unit': 'unit',
      'date': '19 Apr 2026',
      'time': '14:45',
      'by': 'Ahmad Fauzi',
      'warehouse': 'Gudang IPAL · Rak B-12',
      'notes': 'Restok bulanan dari distributor utama',
    },
    {
      'type': 'keluar',
      'item': 'Diffuser Gelembung Halus 9"',
      'code': 'TRX-2026041918',
      'qty': 30,
      'unit': 'unit',
      'date': '19 Apr 2026',
      'time': '11:30',
      'by': 'Dewi Lestari',
      'warehouse': 'Gudang IPAL · Rak C-05',
      'notes': 'Instalasi tangki aerasi proyek WWTP Cikarang',
    },
    {
      'type': 'keluar',
      'item': 'Pipa PVC AW 2" / 6m',
      'code': 'TRX-2026041917',
      'qty': 50,
      'unit': 'meter',
      'date': '19 Apr 2026',
      'time': '09:00',
      'by': 'Reza Permana',
      'warehouse': 'Gudang IPAL · Rak D-02',
      'notes': 'Pemasangan jalur outlet IPAL klien korporat',
    },
    {
      'type': 'transfer',
      'item': 'MCB 3 Phase 16A',
      'code': 'TRF-2026041816',
      'qty': 15,
      'unit': 'unit',
      'date': '18 Apr 2026',
      'time': '16:20',
      'by': 'Rudi Hermawan',
      'warehouse': 'Gudang IPAL C → Gudang IPAL A',
      'notes': 'Konsolidasi stok panel kontrol pusat',
    },
    {
      'type': 'masuk',
      'item': 'Media Karbon Aktif 25kg',
      'code': 'TRX-2026041815',
      'qty': 40,
      'unit': 'kg',
      'date': '18 Apr 2026',
      'time': '13:10',
      'by': 'Ahmad Fauzi',
      'warehouse': 'Gudang IPAL · Rak B-09',
      'notes': 'PO batch Q2 2026 — media filter',
    },
    {
      'type': 'keluar',
      'item': 'Ball Valve PVC 2"',
      'code': 'TRX-2026041814',
      'qty': 18,
      'unit': 'unit',
      'date': '18 Apr 2026',
      'time': '10:10',
      'by': 'Siti Rahayu',
      'warehouse': 'Gudang IPAL · Rak D-08',
      'notes': 'Penggantian valve bocor di area pre-treatment',
    },
    {
      'type': 'masuk',
      'item': 'Bearing 6206 ZZ',
      'code': 'TRX-2026041713',
      'qty': 60,
      'unit': 'unit',
      'date': '17 Apr 2026',
      'time': '15:30',
      'by': 'Ahmad Fauzi',
      'warehouse': 'Gudang IPAL · Rak A-11',
      'notes': 'Restok spare part pompa & blower',
    },
    {
      'type': 'transfer',
      'item': 'Panel Box IP54 600x400',
      'code': 'TRF-2026041712',
      'qty': 4,
      'unit': 'unit',
      'date': '17 Apr 2026',
      'time': '11:00',
      'by': 'Budi Santoso',
      'warehouse': 'Gudang IPAL B → Gudang IPAL A',
      'notes': 'Persiapan proyek panel kontrol IPAL Plant 03',
    },
    {
      'type': 'keluar',
      'item': 'UV Sterilizer 11W',
      'code': 'TRX-2026041711',
      'qty': 6,
      'unit': 'unit',
      'date': '17 Apr 2026',
      'time': '08:45',
      'by': 'Dewi Lestari',
      'warehouse': 'Gudang IPAL · Rak B-15',
      'notes': 'Pengiriman ke unit polishing IPAL klien',
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 0) return _history;
    final type = _filters[_selectedFilter].toLowerCase();
    return _history.where((h) => h['type'] == type).toList();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'masuk':
        return AppTheme.statusApproved;
      case 'keluar':
        return AppTheme.statusRejected;
      case 'transfer':
        return AppTheme.primaryLight;
      default:
        return AppTheme.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'masuk':
        return Icons.south_rounded;
      case 'keluar':
        return Icons.north_rounded;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.circle;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'masuk':
        return 'MASUK';
      case 'keluar':
        return 'KELUAR';
      case 'transfer':
        return 'TRANSFER';
      default:
        return type.toUpperCase();
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded,
                  color: Colors.white, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded,
                  color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats bar
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildMiniStat(
                    'Total',
                    '${_history.length}',
                    Icons.receipt_long_rounded,
                    Colors.white,
                  ),
                  _buildMiniStat(
                    'Masuk',
                    '${_history.where((h) => h['type'] == 'masuk').length}',
                    Icons.south_rounded,
                    AppTheme.bgApproved,
                  ),
                  _buildMiniStat(
                    'Keluar',
                    '${_history.where((h) => h['type'] == 'keluar').length}',
                    Icons.north_rounded,
                    AppTheme.bgRejected,
                  ),
                  _buildMiniStat(
                    'Transfer',
                    '${_history.where((h) => h['type'] == 'transfer').length}',
                    Icons.swap_horiz_rounded,
                    AppTheme.primaryPale,
                  ),
                ],
              ),
            ),

            // Filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: _filters.asMap().entries.map((e) {
                  final isSelected = _selectedFilter == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.primaryLight.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.white : AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // History list
            Expanded(
              child: _filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada riwayat',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = _filteredHistory[index];
                        final showDate = index == 0 ||
                            _filteredHistory[index - 1]['date'] != item['date'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['date'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildHistoryItem(item),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final color = _typeColor(type);

    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon(type), color: color, size: 22),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item['code']}  •  ${item['time']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 11, color: AppTheme.primary),
                      const SizedBox(width: 3),
                      Text(
                        '${item['by']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Qty badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    '${type == 'keluar' ? '-' : '+'}${item['qty']} ${item['unit']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _typeLabel(type),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Detail Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow('Kode', item['code'] as String),
            _detailRow('Nama Barang', item['item'] as String),
            _detailRow('Jenis', _typeLabel(item['type'] as String)),
            _detailRow('Jumlah', '${item['qty']} ${item['unit']}'),
            _detailRow('Gudang', item['warehouse'] as String),
            _detailRow('Oleh', item['by'] as String),
            _detailRow('Tanggal', '${item['date']}  ${item['time']}'),
            _detailRow('Catatan', item['notes'] as String),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey.shade400)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
