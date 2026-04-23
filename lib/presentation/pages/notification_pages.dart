import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification Page — Pusat semua update GudangPro IPAL
//
// Kategori notifikasi:
//   • request      — update status request (disetujui/ditolak/selesai)
//   • pengambilan  — bukti pengambilan diterima/diverifikasi
//   • chat         — pesan baru dari admin
//   • stok         — peringatan stok rendah/kritis
//   • sistem       — update aplikasi, login, laporan, dll
//
// Fitur:
//   • Filter chip per kategori
//   • Group otomatis (Hari Ini / Kemarin / Sebelumnya)
//   • Tandai semua sebagai dibaca
//   • Hapus 1 notifikasi via swipe
//   • Empty state per kondisi
// ─────────────────────────────────────────────────────────────────────────────

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  String _filter = 'all';

  // Daftar kategori filter (label + value)
  static const _categories = <Map<String, String>>[
    {'value': 'all', 'label': 'Semua'},
    {'value': 'request', 'label': 'Request'},
    {'value': 'pengambilan', 'label': 'Pengambilan'},
    {'value': 'chat', 'label': 'Chat'},
    {'value': 'stok', 'label': 'Stok'},
    {'value': 'sistem', 'label': 'Sistem'},
  ];

  // Sumber data notifikasi (dummy, konteks IPAL)
  late final List<Map<String, dynamic>> _notifications = [
    {
      'category': 'request',
      'title': 'Request Disetujui',
      'body':
          'Request "Pompa Submersible 1HP" (5 unit) sudah disetujui oleh Reza Permana. Silakan ambil di gudang.',
      'minutesAgo': 4,
      'read': false,
    },
    {
      'category': 'chat',
      'title': 'Pesan Baru dari Admin',
      'body':
          'Ahmad Fauzi: "Stok membran filter sudah datang pak, silakan request kalau butuh."',
      'minutesAgo': 12,
      'read': false,
    },
    {
      'category': 'stok',
      'title': 'Stok Kritis: Klorin Cair 30%',
      'body':
          'Stok Klorin Cair 30% (B07) tinggal 2 jerigen. Segera ajukan restok agar IPAL tetap operasional.',
      'minutesAgo': 35,
      'read': false,
    },
    {
      'category': 'pengambilan',
      'title': 'Bukti Pengambilan Diterima',
      'body':
          'Bukti pengambilan "Selang HDPE 2 inch" sudah diverifikasi admin gudang. Status request: Selesai.',
      'minutesAgo': 90,
      'read': true,
    },
    {
      'category': 'request',
      'title': 'Request Ditolak',
      'body':
          'Request "Pompa Dosing 5 LPH" ditolak. Alasan: stok di gudang masih cukup untuk 2 minggu ke depan.',
      'minutesAgo': 180,
      'read': true,
    },
    {
      'category': 'sistem',
      'title': 'Laporan Mingguan Tersedia',
      'body':
          'Laporan aktivitas gudang IPAL minggu ini sudah dapat diunduh. Periode: 13–19 April 2026.',
      'minutesAgo': 60 * 6,
      'read': true,
    },
    {
      'category': 'sistem',
      'title': 'Login Baru Terdeteksi',
      'body':
          'Login baru ke akun Anda dari perangkat baru. Jika bukan Anda, segera ubah kata sandi.',
      'minutesAgo': 60 * 24 + 60,
      'read': true,
    },
    {
      'category': 'stok',
      'title': 'Stok Kritis: Tawas Bubuk 25Kg',
      'body':
          'Stok Tawas Bubuk 25Kg tinggal 5 sak. Segera lakukan restok ke supplier.',
      'minutesAgo': 60 * 30,
      'read': true,
    },
    {
      'category': 'sistem',
      'title': 'Pembaruan Sistem v1.0.1',
      'body':
          'GudangPro diperbarui ke versi 1.0.1. Beberapa peningkatan performa dan perbaikan bug telah dilakukan.',
      'minutesAgo': 60 * 48,
      'read': true,
    },
  ];

  // ── Helpers ──────────────────────────────────────────────────────────────
  int get _unreadCount => _notifications.where((n) => !(n['read'] as bool)).length;

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'all'
          ? _notifications
          : _notifications.where((n) => n['category'] == _filter).toList();

  // Group notifikasi: 0 = Hari Ini (<24 jam), 1 = Kemarin (<48 jam), 2 = Sebelumnya
  int _bucket(int minutes) {
    if (minutes < 60 * 24) return 0;
    if (minutes < 60 * 48) return 1;
    return 2;
  }

  String _bucketLabel(int b) {
    switch (b) {
      case 0:
        return 'Hari Ini';
      case 1:
        return 'Kemarin';
      default:
        return 'Sebelumnya';
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 1) return 'Baru saja';
    if (minutes < 60) return '$minutes menit lalu';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours jam lalu';
    final days = hours ~/ 24;
    if (days == 1) return 'Kemarin';
    if (days < 7) return '$days hari lalu';
    return '${days ~/ 7} minggu lalu';
  }

  _CategoryMeta _meta(String category) {
    switch (category) {
      case 'request':
        return _CategoryMeta(
          color: AppTheme.statusApproved,
          bg: AppTheme.bgApproved,
          icon: Icons.assignment_turned_in_rounded,
          label: 'Request',
        );
      case 'pengambilan':
        return _CategoryMeta(
          color: AppTheme.statusCompleted,
          bg: AppTheme.bgCompleted,
          icon: Icons.outbox_rounded,
          label: 'Pengambilan',
        );
      case 'chat':
        return _CategoryMeta(
          color: AppTheme.primary,
          bg: AppTheme.primary.withOpacity(0.1),
          icon: Icons.chat_rounded,
          label: 'Chat',
        );
      case 'stok':
        return _CategoryMeta(
          color: AppTheme.statusRejected,
          bg: AppTheme.bgRejected,
          icon: Icons.warning_amber_rounded,
          label: 'Stok',
        );
      case 'sistem':
      default:
        return _CategoryMeta(
          color: const Color(0xFF546E7A),
          bg: const Color(0xFFECEFF1),
          icon: Icons.system_update_rounded,
          label: 'Sistem',
        );
    }
  }

  int _categoryCount(String value) {
    if (value == 'all') return _notifications.length;
    return _notifications.where((n) => n['category'] == value).length;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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

  // ── Actions ──────────────────────────────────────────────────────────────
  void _markAllRead() {
    HapticFeedback.selectionClick();
    setState(() {
      for (final n in _notifications) {
        n['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai dibaca',
            style: TextStyle(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleRead(Map<String, dynamic> n) {
    HapticFeedback.selectionClick();
    setState(() => n['read'] = !(n['read'] as bool));
  }

  void _delete(Map<String, dynamic> n) {
    setState(() => _notifications.remove(n));
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.bgPending,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.construction_rounded,
                  color: AppTheme.statusPending, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Sedang Dikembangkan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: const Text(
          'Pengaturan notifikasi sedang dalam tahap pengembangan dan akan '
          'segera tersedia di update berikutnya.',
          style: TextStyle(fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(child: _buildFilterChips()),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(),
                )
              else
                ..._buildGroupedSlivers(list),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header (SliverAppBar) ────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryDark,
      actions: [
        if (_unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all_rounded,
                color: Colors.white, size: 16),
            label: const Text(
              'Tandai dibaca',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 21),
          onPressed: _openSettings,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Notifikasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_unreadCount baru',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semua update gudang IPAL ada di sini',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
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

  // ── Filter Chips ─────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = _categories[i];
          final value = c['value']!;
          final selected = _filter == value;
          final isAll = value == 'all';
          final accent =
              isAll ? AppTheme.primary : _meta(value).color;
          final count = _categoryCount(value);

          return GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? accent : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.25)
                          : accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_off_rounded,
                  size: 42, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _filter == 'all'
                  ? 'Belum ada notifikasi'
                  : 'Tidak ada notifikasi di kategori ini',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Update gudang dan request akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grouped Slivers ──────────────────────────────────────────────────────
  List<Widget> _buildGroupedSlivers(List<Map<String, dynamic>> list) {
    // Kelompokkan berdasarkan bucket
    final Map<int, List<Map<String, dynamic>>> groups = {};
    for (final n in list) {
      final b = _bucket(n['minutesAgo'] as int);
      groups.putIfAbsent(b, () => []).add(n);
    }
    final keys = groups.keys.toList()..sort();

    final widgets = <Widget>[];
    for (final k in keys) {
      widgets.add(SliverToBoxAdapter(child: _buildSectionHeader(_bucketLabel(k))));
      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: groups[k]!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildNotificationItem(groups[k]![i]),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification Item ────────────────────────────────────────────────────
  Widget _buildNotificationItem(Map<String, dynamic> n) {
    final isUnread = !(n['read'] as bool);
    final meta = _meta(n['category'] as String);

    return Dismissible(
      key: ValueKey(n),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppTheme.statusRejected,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text('Hapus',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) => _delete(n),
      child: GestureDetector(
        onTap: () => _toggleRead(n),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread
                  ? meta.color.withOpacity(0.3)
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: meta.color.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(meta.icon, color: meta.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: meta.bg,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            meta.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: meta.color,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: meta.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isUnread
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n['body'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isUnread
                            ? Colors.grey.shade700
                            : Colors.grey.shade500,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(n['minutesAgo'] as int),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _CategoryMeta {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;
  const _CategoryMeta({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });
}
