import 'package:flutter/material.dart';
import 'package:warehouse_user_1/presentation/pages/barcode_pages.dart';
import 'package:warehouse_user_1/presentation/pages/detail_chat_pages.dart';
import 'package:warehouse_user_1/presentation/pages/detail_item.dart';
import 'package:warehouse_user_1/presentation/pages/detail_request_pages.dart';
import 'package:warehouse_user_1/presentation/pages/item_database_dummy.dart';
import 'package:warehouse_user_1/presentation/pages/list_item.dart';
import 'package:warehouse_user_1/presentation/pages/list_request_pages.dart';
import 'package:warehouse_user_1/presentation/pages/request_pages.dart';
import 'app_theme.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Home — Warehouse User
// Ganti class HomePage yang lama dengan file ini.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Data user ──────────────────────────────────────────────────────────────
  static const _userName = 'Budi Santoso';
  static const _userInitials = 'BS';
  static const _userDivisi = 'Divisi IPAL';
  static const _userCabang = 'Unit Pengolahan Utama';

  // ── Data request ──────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _myRequests = [
    {
      'code': 'REQ-20260420-001',
      'item': 'Pompa Submersible 7.5 kW',
      'qty': 1,
      'unit': 'unit',
      'date': '20 Apr 2026',
      'status': 'pending',
      'approver': '-',
      'notes': 'Pengganti pompa inlet yang rusak',
    },
    {
      'code': 'REQ-20260419-003',
      'item': 'Media Filter Bioball',
      'qty': 50,
      'unit': 'kg',
      'date': '19 Apr 2026',
      'status': 'approved',
      'approver': 'Ahmad Fauzi',
      'notes': 'Pengisian ulang reaktor biofilm',
    },
    {
      'code': 'REQ-20260418-002',
      'item': 'Membran Ultrafiltrasi 0.02μm',
      'qty': 2,
      'unit': 'modul',
      'date': '18 Apr 2026',
      'status': 'rejected',
      'approver': 'Siti Rahayu',
      'notes': 'Penggantian membran tersumbat',
    },
    {
      'code': 'REQ-20260415-005',
      'item': 'Blower Aerasi Roots 3 kW',
      'qty': 1,
      'unit': 'unit',
      'date': '15 Apr 2026',
      'status': 'completed',
      'approver': 'Ahmad Fauzi',
      'notes': 'Pengganti blower basin aerasi',
    },
    {
      'code': 'REQ-20260410-004',
      'item': 'pH Meter Digital Portabel',
      'qty': 2,
      'unit': 'unit',
      'date': '10 Apr 2026',
      'status': 'approved',
      'approver': 'Ahmad Fauzi',
      'notes': 'Alat ukur kualitas efluen',
    },
    {
      'code': 'REQ-20260405-008',
      'item': 'Dosing Pump Kimia 12 L/h',
      'qty': 1,
      'unit': 'unit',
      'date': '05 Apr 2026',
      'status': 'completed',
      'approver': 'Siti Rahayu',
      'notes': 'Untuk injeksi koagulan PAC',
    },
  ];

  // ── Barang sering diminta user ─────────────────────────────────────────────
  // ── Barang sering diminta diambil dari item_database (list barang) ────────
  // ID dipilih dari kategori populer; totalRequests deterministik dari hash id.
  static const List<String> _favoriteIds = [
    'P02', // Pompa Submersible 1 HP
    'F11', // Media Karbon Aktif 25kg
    'B02', // Blower Roots 1 HP
    'K30', // HMI Display 4.3"
    'F30', // Kaporit Tablet 1kg
    'S05', // Pipa PVC AW 2"
  ];

  List<Map<String, dynamic>> get _favoriteItems {
    final all = getAllItems();
    final byId = {for (final it in all) it.id: it};
    final result = <Map<String, dynamic>>[];
    for (final id in _favoriteIds) {
      final it = byId[id];
      if (it == null) continue;
      final cat = categoryByName(it.category);
      final history = historyForItem(it.id);
      result.add({
        'item': it, // simpan IpalItem untuk navigasi ke DetailItemPage
        'name': it.name,
        'code': it.id,
        'icon': cat.icon,
        'color': cat.color,
        'stock': it.stock,
        'available': it.stock > 0,
        'lastRequest': history.isNotEmpty ? history.first['date'] ?? '-' : '-',
        'totalRequests': history.length,
        'unit': it.unit,
      });
    }
    return result;
  }

  // ── (DIHAPUS) data favorit statis lama ────────────────────────────────────
  // ignore: unused_field
  final List<Map<String, dynamic>> _favoriteItemsLegacy_unused = [
    {
      'name': 'Pompa Submersible 7.5 kW',
      'code': 'PUMP-001',
      'icon': Icons.water_drop_rounded,
      'color': AppTheme.primary,
      'stock': 4,
      'available': true,
      'lastRequest': '20 Apr 2026',
      'totalRequests': 5,
      'unit': 'unit',
    },
    {
      'name': 'Kaporit Ca(OCl)₂ 65%',
      'code': 'KAPT-007',
      'icon': Icons.science_rounded,
      'color': AppTheme.statusApproved,
      'stock': 120,
      'available': true,
      'lastRequest': '18 Apr 2026',
      'totalRequests': 4,
      'unit': 'kg',
    },
    {
      'name': 'Blower Aerasi Roots 3 kW',
      'code': 'BLWR-004',
      'icon': Icons.air_rounded,
      'color': const Color(0xFF7B1FA2),
      'stock': 2,
      'available': true,
      'lastRequest': '15 Apr 2026',
      'totalRequests': 3,
      'unit': 'unit',
    },
    {
      'name': 'Media Filter Bioball',
      'code': 'BBIO-002',
      'icon': Icons.bubble_chart_rounded,
      'color': AppTheme.statusCompleted,
      'stock': 0,
      'available': false,
      'lastRequest': '19 Apr 2026',
      'totalRequests': 3,
      'unit': 'kg',
    },
  ];

  // ── Info stock barang sering dipakai (ambil dari item_database) ───────────
  static const List<String> _stockInfoIds = [
    'P03', // Pompa Submersible 2 HP
    'F11', // Media Karbon Aktif 25kg
    'B07', // Diffuser Gelembung Halus 12"
    'K20', // Box Panel IP54 400x300
    'R09', // Baut M10x30
    'S05', // Pipa PVC AW 2"
  ];

  List<Map<String, dynamic>> get _stockInfo {
    final all = getAllItems();
    final byId = {for (final it in all) it.id: it};
    final result = <Map<String, dynamic>>[];
    for (final id in _stockInfoIds) {
      final it = byId[id];
      if (it == null) continue;
      final cat = categoryByName(it.category);
      final s = stockStatusOf(it.stock);
      result.add({
        'item': it, // simpan IpalItem untuk navigasi
        'name': it.name,
        'code': it.id,
        'icon': cat.icon,
        'color': cat.color,
        'stock': it.stock,
        'unit': it.unit,
        'status': s == StockStatus.available
            ? 'available'
            : s == StockStatus.low
                ? 'low'
                : 'empty',
      });
    }
    return result;
  }

  // ── (DIHAPUS) data stok statis lama ──────────────────────────────────────
  // ignore: unused_field
  final List<Map<String, dynamic>> _stockInfoLegacy_unused = [
    {
      'name': 'Pompa Submersible 7.5 kW',
      'code': 'PUMP-001',
      'icon': Icons.water_drop_rounded,
      'color': AppTheme.primary,
      'stock': 4,
      'unit': 'unit',
      'status': 'available',
    },
    {
      'name': 'Media Filter Bioball',
      'code': 'BBIO-002',
      'icon': Icons.bubble_chart_rounded,
      'color': AppTheme.statusCompleted,
      'stock': 0,
      'unit': 'kg',
      'status': 'empty',
    },
    {
      'name': 'Membran Ultrafiltrasi 0.02μm',
      'code': 'MEMB-003',
      'icon': Icons.filter_alt_rounded,
      'color': AppTheme.primaryDark,
      'stock': 2,
      'unit': 'modul',
      'status': 'low',
    },
    {
      'name': 'Kaporit Ca(OCl)₂ 65%',
      'code': 'KAPT-007',
      'icon': Icons.science_rounded,
      'color': AppTheme.statusApproved,
      'stock': 120,
      'unit': 'kg',
      'status': 'available',
    },
    {
      'name': 'Pipa HDPE PN10 DN100',
      'code': 'HDPE-006',
      'icon': Icons.plumbing_rounded,
      'color': const Color(0xFFFF7043),
      'stock': 8,
      'unit': 'batang',
      'status': 'low',
    },
    {
      'name': 'Flow Meter Electromagnetic',
      'code': 'FMTR-008',
      'icon': Icons.speed_rounded,
      'color': AppTheme.statusPending,
      'stock': 1,
      'unit': 'unit',
      'status': 'low',
    },
  ];

  // ── Notifikasi ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'approved',
      'title': 'Request Disetujui',
      'message':
          'Media Filter Bioball (REQ-20260419-003) telah disetujui oleh Ahmad Fauzi.',
      'time': '2 jam lalu',
      'read': false,
    },
    {
      'type': 'ready',
      'title': 'Barang Siap Diambil',
      'message':
          'Blower Aerasi Roots 3 kW (REQ-20260415-005) siap diambil di Gudang IPAL.',
      'time': '1 hari lalu',
      'read': false,
    },
    {
      'type': 'rejected',
      'title': 'Request Ditolak',
      'message':
          'Membran Ultrafiltrasi (REQ-20260418-002) ditolak. Stok sedang dalam pengadaan.',
      'time': '2 hari lalu',
      'read': true,
    },
    {
      'type': 'info',
      'title': 'Stock Hampir Habis',
      'message':
          'Pipa HDPE PN10 DN100 (HDPE-006) tersisa 8 batang. Segera ajukan request.',
      'time': '3 hari lalu',
      'read': true,
    },
  ];

  // ── Pengumuman ─────────────────────────────────────────────────────────────
  // ignore: unused_field
  final List<Map<String, dynamic>> _announcements = [
    {
      'icon': Icons.build_rounded,
      'color': const Color(0xFFFF7043),
      'title': 'Kalibrasi Alat Ukur IPAL',
      'content':
          'Seluruh sensor pH, DO, dan turbidity wajib dikalibrasi pada 25–26 Apr 2026. Aktivitas pengolahan tetap berjalan.',
      'date': '20 Apr 2026',
      'tag': 'Penting',
      'tagColor': const Color(0xFFFF7043),
    },
    {
      'icon': Icons.schedule_rounded,
      'color': AppTheme.primary,
      'title': 'Jam Operasional Gudang IPAL',
      'content':
          'Senin–Jumat: 07.00–16.00 WIB. Pengambilan bahan kimia wajib disertai MSDS dan APD lengkap.',
      'date': '15 Apr 2026',
      'tag': 'Info',
      'tagColor': AppTheme.primary,
    },
    {
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFF7B1FA2),
      'title': 'Prosedur Baru Bahan Kimia B3',
      'content':
          'Mulai 1 Mei 2026, permintaan bahan kimia B3 wajib disertai surat persetujuan K3 dan lembar MSDS terbaru.',
      'date': '10 Apr 2026',
      'tag': 'Internal',
      'tagColor': const Color(0xFF7B1FA2),
    },
  ];

  // ── Computed counts ────────────────────────────────────────────────────────
  int get _totalBulanIni => _myRequests.length;
  int get _pendingCount =>
      _myRequests.where((r) => r['status'] == 'pending').length;
  int get _approvedCount =>
      _myRequests.where((r) => r['status'] == 'approved').length;
  int get _rejectedCount =>
      _myRequests.where((r) => r['status'] == 'rejected').length;
  int get _completedCount =>
      _myRequests.where((r) => r['status'] == 'completed').length;
  int get _unreadNotifCount =>
      _notifications.where((n) => n['read'] == false).length;

  List<Map<String, dynamic>> get _recentRequests =>
      _myRequests.take(5).toList();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGASI KE HALAMAN REQUEST
  // ══════════════════════════════════════════════════════════════════════════

  void _openRequestPage({Map<String, dynamic>? prefill}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RequestPage(prefillItem: prefill)),
    );
  }

  void _openDetailRequest(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailRequestPage(item: item)),
    );
  }

  void _openListItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ListItemPage()),
    );
  }

  void _openDetailItem(IpalItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailItemPage(item: item)),
    );
  }

  void _openScanBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanBarcodePage()),
    );
  }

  void _openChatAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DetailChatPage()),
    );
  }

  void _openListRequest({String? status, bool focusSearch = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListRequestPage(
          requests: _myRequests,
          initialStatus: status,
          autoFocusSearch: focusSearch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightOverlay,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _buildSearchBar(),
                    const SizedBox(height: 22),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildStockInfo(),
                    const SizedBox(height: 24),
                    _buildFavoriteItems(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                right: 60,
                bottom: -16,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Senin, 21 April 2026',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Halo, $_userName! 👋',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.business_rounded,
                                        size: 11,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _userDivisi,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_city_rounded,
                                        size: 11,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _userCabang,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, AppTheme.primarySurface],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            _userInitials,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (_unreadNotifCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.statusRejected,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$_unreadNotifCount',
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _openListRequest(focusSearch: true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.search_rounded,
                    size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari request, kode barang, atau catatan...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.tune_rounded,
                    size: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUMMARY CARDS — REMOVED (digantikan oleh search bar di atas)
  // ══════════════════════════════════════════════════════════════════════════

  // ignore: unused_element
  Widget _buildSummaryCards_removed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.bar_chart_rounded,
          title: 'Ringkasan Request',
          subtitle: 'Bulan April 2026 · Ketuk untuk detail',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 102,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildSummaryCard(
                label: 'Total Bulan Ini',
                value: '$_totalBulanIni',
                icon: Icons.receipt_long_rounded,
                gradient: const [AppTheme.primary, AppTheme.primaryDark],
                isHighlight: true,
                onTap: () => _showRequestSheet(null, 'Semua Request',
                    const [AppTheme.primary, AppTheme.primaryDark]),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Pending',
                value: '$_pendingCount',
                icon: Icons.hourglass_empty_rounded,
                gradient: const [AppTheme.statusPending, Color(0xFFFF8F00)],
                onTap: () => _showRequestSheet('pending', 'Request Pending',
                    const [AppTheme.statusPending, Color(0xFFFF8F00)]),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Disetujui',
                value: '$_approvedCount',
                icon: Icons.check_circle_rounded,
                gradient: const [Color(0xFF26C6DA), Color(0xFF00ACC1)],
                onTap: () => _showRequestSheet('approved', 'Request Disetujui',
                    const [Color(0xFF26C6DA), Color(0xFF00ACC1)]),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Ditolak',
                value: '$_rejectedCount',
                icon: Icons.cancel_rounded,
                gradient: const [Color(0xFFEF5350), Color(0xFFE53935)],
                onTap: () => _showRequestSheet('rejected', 'Request Ditolak',
                    const [Color(0xFFEF5350), Color(0xFFE53935)]),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                label: 'Selesai',
                value: '$_completedCount',
                icon: Icons.task_alt_rounded,
                gradient: const [Color(0xFF26A69A), AppTheme.statusCompleted],
                onTap: () => _showRequestSheet('completed', 'Request Selesai',
                    const [Color(0xFF26A69A), AppTheme.statusCompleted]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isHighlight ? 140 : 116,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 28 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET — DETAIL REQUEST PER STATUS
  // ══════════════════════════════════════════════════════════════════════════

  void _showRequestSheet(String? filter, String title, List<Color> gradient) {
    final items = filter == null
        ? _myRequests
        : _myRequests.where((r) => r['status'] == filter).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.40,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary)),
                          Text('${items.length} request · Bulan April 2026',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                  color: AppTheme.background,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.inbox_rounded,
                                  color: AppTheme.primary, size: 28),
                            ),
                            const SizedBox(height: 12),
                            Text('Tidak ada request di kategori ini',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _buildSheetRequestCard(items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetRequestCard(Map<String, dynamic> req) {
    final status = req['status'] as String;
    final meta = _statusMeta(status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req['item'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.3)),
                    const SizedBox(height: 2),
                    Text(req['code'] as String,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: meta.bg, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(meta.icon, color: meta.color, size: 11),
                    const SizedBox(width: 3),
                    Text(meta.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: meta.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.shade50),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _buildDetailItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Jumlah',
                    value: '${req['qty']} ${req['unit'] ?? 'unit'}')),
            Expanded(
                child: _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal',
                    value: req['date'] as String)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _buildDetailItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Approver',
                    value: req['approver'] as String)),
            Expanded(
                child: _buildDetailItem(
                    icon: Icons.notes_rounded,
                    label: 'Catatan',
                    value: req['notes'] as String,
                    truncate: true)),
          ]),
          if (status == 'pending' || status == 'approved') ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: status == 'pending' ? 0.2 : 0.65,
                minHeight: 5,
                backgroundColor: meta.color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(meta.color),
              ),
            ),
            const SizedBox(height: 3),
            Text(
                status == 'pending'
                    ? 'Menunggu persetujuan...'
                    : 'Sedang diproses...',
                style: TextStyle(
                    fontSize: 10,
                    color: meta.color,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      {required IconData icon,
      required String label,
      required String value,
      bool truncate = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppTheme.primary),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                  maxLines: truncate ? 1 : null,
                  overflow: truncate ? TextOverflow.ellipsis : null),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOMBOL CEPAT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.bolt_rounded,
          title: 'Aksi Cepat',
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.add_box_rounded,
                  label: 'Buat Request\nBarang',
                  gradient: const [AppTheme.primary, AppTheme.primaryDark],
                  isPrimary: true,
                  onTap: () => _openRequestPage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.receipt_long_rounded,
                  label: 'Lihat Semua\nRequest',
                  gradient: const [AppTheme.primaryLight, AppTheme.primary],
                  onTap: () => _openListRequest(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan\nBarcode',
                  gradient: const [Color(0xFF26A69A), AppTheme.statusCompleted],
                  onTap: _openScanBarcode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.chat_rounded,
                  label: 'Chat\nAdmin',
                  gradient: const [Color(0xFF7B1FA2), Color(0xFF6A1B9A)],
                  onTap: _openChatAdmin,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS REQUEST TERBARU
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRecentRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildSectionTitle(
                icon: Icons.history_rounded,
                title: 'Request Terbaru',
                inline: true,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openListRequest(),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _recentRequests
                .map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildRecentRequestCard(req),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRequestCard(Map<String, dynamic> req) {
    final status = req['status'] as String;
    final _StatusMeta meta = _statusMeta(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetailRequest(req),
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'pending'
              ? meta.color.withOpacity(0.25)
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meta.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(meta.icon, color: meta.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req['item'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        req['code'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        req['date'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (status == 'pending' || status == 'approved') ...[
                    _buildProgressBar(status),
                    const SizedBox(height: 2),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: meta.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(meta.icon, color: meta.color, size: 11),
                  const SizedBox(width: 3),
                  Text(
                    meta.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: meta.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
      ),
    );
  }

  Widget _buildProgressBar(String status) {
    double progress;
    Color color;
    String label;

    if (status == 'pending') {
      progress = 0.2;
      color = AppTheme.statusPending;
      label = 'Menunggu persetujuan...';
    } else {
      progress = 0.65;
      color = AppTheme.statusApproved;
      label = 'Sedang diproses...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BARANG SERING DIMINTA
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFavoriteItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionTitle(
            icon: Icons.star_rounded,
            title: 'Barang Sering Diminta',
            subtitle: 'Klik untuk lihat detail & request ulang',
            inline: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _favoriteItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildFavoriteCard(_favoriteItems[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final isAvailable = item['available'] as bool;
    final ipal = item['item'] as IpalItem?;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              if (ipal != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailItemPage(item: ipal)),
                );
              } else {
                _openDetailRequest(item);
              }
            }
          : null,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 20),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.replay_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item['name'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.loop_rounded,
                    size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(
                  '${item['totalRequests']}x request',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppTheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAvailable ? 'Lihat Detail' : 'Stok Habis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isAvailable ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFIKASI
  // ══════════════════════════════════════════════════════════════════════════

  // ignore: unused_element
  Widget _buildNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildSectionTitle(
                icon: Icons.notifications_rounded,
                title: 'Notifikasi',
                inline: true,
              ),
              const Spacer(),
              if (_unreadNotifCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.statusRejected,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$_unreadNotifCount baru',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _notifications
                .map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildNotifCard(n),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> notif) {
    final type = notif['type'] as String;
    final isUnread = notif['read'] == false;

    Color color;
    Color bg;
    IconData icon;

    switch (type) {
      case 'approved':
        color = AppTheme.statusApproved;
        bg = AppTheme.bgApproved;
        icon = Icons.check_circle_rounded;
        break;
      case 'ready':
        color = AppTheme.primary;
        bg = AppTheme.primarySurface;
        icon = Icons.inventory_rounded;
        break;
      case 'rejected':
        color = AppTheme.statusRejected;
        bg = AppTheme.bgRejected;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = AppTheme.statusPending;
        bg = AppTheme.bgPending;
        icon = Icons.info_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.2) : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUnread
                              ? AppTheme.textPrimary
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif['message'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notif['time'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INFO STOCK RINGKAS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStockInfo() {
    final available =
        _stockInfo.where((s) => s['status'] == 'available').toList();
    final low = _stockInfo.where((s) => s['status'] == 'low').toList();
    final empty = _stockInfo.where((s) => s['status'] == 'empty').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  icon: Icons.inventory_2_rounded,
                  title: 'Info Stock Barang',
                  subtitle: 'Barang yang sering kamu pakai',
                ),
              ),
              GestureDetector(
                onTap: _openListItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.primary, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      _buildStockLegend(AppTheme.statusApproved,
                          'Tersedia (${available.length})'),
                      const SizedBox(width: 16),
                      _buildStockLegend(AppTheme.statusPending,
                          'Hampir Habis (${low.length})'),
                      const SizedBox(width: 16),
                      _buildStockLegend(
                          Colors.grey.shade400, 'Kosong (${empty.length})'),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ...List.generate(_stockInfo.length, (i) {
                  final item = _stockInfo[i];
                  return _buildStockRow(
                    item,
                    isLast: i == _stockInfo.length - 1,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStockRow(Map<String, dynamic> item, {required bool isLast}) {
    final status = item['status'] as String;
    final color = item['color'] as Color;
    final stock = item['stock'] as int;
    final ipal = item['item'] as IpalItem?;

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (status) {
      case 'available':
        statusColor = AppTheme.statusApproved;
        statusBg = AppTheme.bgApproved;
        statusLabel = 'Tersedia';
        break;
      case 'low':
        statusColor = AppTheme.statusPending;
        statusBg = AppTheme.bgPending;
        statusLabel = 'Hampir Habis';
        break;
      default:
        statusColor = Colors.grey.shade500;
        statusBg = Colors.grey.shade100;
        statusLabel = 'Kosong';
    }

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: ipal == null ? null : () => _openDetailItem(ipal),
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      item['code'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stock > 0 ? '$stock ${item['unit']}' : 'Stok 0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade50),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENGUMUMAN
  // ══════════════════════════════════════════════════════════════════════════

  // ignore: unused_element
  Widget _buildAnnouncements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: Icons.campaign_rounded,
          title: 'Pengumuman',
          subtitle: 'Info terbaru dari admin gudang',
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: _announcements
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAnnouncementCard(a),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final tagColor = item['tagColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item['icon'] as IconData, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item['tag'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item['content'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      item['date'] as String,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    String? subtitle,
    bool inline = false,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: AppTheme.primary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ],
    );

    if (inline) return content;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: content,
    );
  }

  _StatusMeta _statusMeta(String status) {
    switch (status) {
      case 'pending':
        return _StatusMeta(
          label: 'Pending',
          color: AppTheme.statusPending,
          bg: AppTheme.bgPending,
          icon: Icons.hourglass_empty_rounded,
        );
      case 'approved':
        return _StatusMeta(
          label: 'Disetujui',
          color: AppTheme.statusApproved,
          bg: AppTheme.bgApproved,
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return _StatusMeta(
          label: 'Ditolak',
          color: AppTheme.statusRejected,
          bg: AppTheme.bgRejected,
          icon: Icons.cancel_rounded,
        );
      case 'completed':
        return _StatusMeta(
          label: 'Selesai',
          color: AppTheme.statusCompleted,
          bg: AppTheme.bgCompleted,
          icon: Icons.task_alt_rounded,
        );
      default:
        return _StatusMeta(
          label: status,
          color: Colors.grey,
          bg: Colors.grey.shade100,
          icon: Icons.circle,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper model
// ─────────────────────────────────────────────────────────────────────────────

class _StatusMeta {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  const _StatusMeta({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}
