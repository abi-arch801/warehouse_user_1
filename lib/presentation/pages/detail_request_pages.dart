import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_user_1/presentation/pages/request_pages.dart';
import 'app_theme.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Detail Request Page — Detail Barang yang Sering Diminta
//
// Dipanggil dari kartu "Barang Sering Diminta" di home page.
// Menampilkan info lengkap barang + tombol "Request Barang Ini" yang
// langsung membuka RequestPage dengan field item ter-prefill.
// ─────────────────────────────────────────────────────────────────────────────

class DetailRequestPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailRequestPage({super.key, required this.item});

  // History request dummy — di production ganti dengan data dari API
  List<Map<String, String>> get _history => const [
        {
          'code': 'REQ-20260420-001',
          'date': '20 Apr 2026',
          'qty': '1 unit',
          'status': 'pending',
          'approver': '-',
        },
        {
          'code': 'REQ-20260315-007',
          'date': '15 Mar 2026',
          'qty': '2 unit',
          'status': 'completed',
          'approver': 'Ahmad Fauzi',
        },
        {
          'code': 'REQ-20260210-012',
          'date': '10 Feb 2026',
          'qty': '1 unit',
          'status': 'completed',
          'approver': 'Siti Rahayu',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final color = (item['color'] as Color?) ?? AppTheme.primary;
    final isAvailable = (item['available'] as bool?) ?? ((item['stock'] ?? 0) > 0);
    final stock = (item['stock'] ?? 0) as int;
    final totalRequests = (item['totalRequests'] ?? 0) as int;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightOverlay,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context, color),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemCard(color, isAvailable, stock),
                    const SizedBox(height: 18),
                    _buildStatsRow(totalRequests, stock),
                    const SizedBox(height: 22),
                    _sectionLabel('Informasi Barang'),
                    const SizedBox(height: 10),
                    _buildInfoCard(),
                    const SizedBox(height: 22),
                    _sectionLabel('Riwayat Request'),
                    const SizedBox(height: 10),
                    ..._history.map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildHistoryCard(h),
                        )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, isAvailable),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color color) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Detail Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lihat detail dan riwayat request barang ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
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
    );
  }

  // ── Item Hero Card ────────────────────────────────────────────────────────
  Widget _buildItemCard(Color color, bool isAvailable, int stock) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  (item['icon'] as IconData?) ?? Icons.inventory_2_rounded,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['name'] ?? '-') as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (item['code'] ?? '-') as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppTheme.statusApproved.withOpacity(0.1)
                  : AppTheme.statusRejected.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 14,
                  color: isAvailable
                      ? AppTheme.statusApproved
                      : AppTheme.statusRejected,
                ),
                const SizedBox(width: 6),
                Text(
                  isAvailable ? 'Tersedia · $stock di gudang' : 'Stok Habis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAvailable
                        ? AppTheme.statusApproved
                        : AppTheme.statusRejected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(int totalRequests, int stock) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.loop_rounded,
            label: 'Total Request',
            value: '$totalRequests',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_rounded,
            label: 'Stok Saat Ini',
            value: '$stock',
            color: AppTheme.statusCompleted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_rounded,
            label: 'Terakhir',
            value: ((item['lastRequest'] ?? '-') as String).split(' ').first,
            color: AppTheme.statusPending,
            isSmall: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          _infoRow(Icons.qr_code_rounded, 'Kode Barang',
              (item['code'] ?? '-') as String),
          _divider(),
          _infoRow(
            Icons.straighten_rounded,
            'Satuan',
            (item['unit'] ?? 'unit') as String,
          ),
          _divider(),
          _infoRow(
            Icons.warehouse_rounded,
            'Lokasi',
            'Gudang IPAL · Rak A-12',
          ),
          _divider(),
          _infoRow(
            Icons.person_outline_rounded,
            'PIC Stok',
            'Ahmad Fauzi',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  // ── History Card ──────────────────────────────────────────────────────────
  Widget _buildHistoryCard(Map<String, String> h) {
    final status = h['status']!;
    Color color;
    Color bg;
    IconData icon;
    String label;

    switch (status) {
      case 'pending':
        color = AppTheme.statusPending;
        bg = AppTheme.bgPending;
        icon = Icons.hourglass_empty_rounded;
        label = 'Pending';
        break;
      case 'approved':
        color = AppTheme.statusApproved;
        bg = AppTheme.bgApproved;
        icon = Icons.check_circle_rounded;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = AppTheme.statusRejected;
        bg = AppTheme.bgRejected;
        icon = Icons.cancel_rounded;
        label = 'Ditolak';
        break;
      default:
        color = AppTheme.statusCompleted;
        bg = AppTheme.bgCompleted;
        icon = Icons.task_alt_rounded;
        label = 'Selesai';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h['code']!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      h['date']!,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                    Text('  ·  ',
                        style: TextStyle(color: Colors.grey.shade300)),
                    Text(
                      h['qty']!,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, bool isAvailable) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAvailable
                ? () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestPage(prefillItem: item),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade400,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAvailable ? Icons.add_box_rounded : Icons.block_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isAvailable ? 'Request Barang Ini' : 'Stok Habis',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
