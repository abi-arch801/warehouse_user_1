import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_user_1/presentation/pages/detail_chat_pages.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// List Request Page — Daftar Semua Request
//
// Bisa dipanggil dengan:
//  - tanpa argumen  -> tampilkan semua
//  - initialQuery   -> langsung filter berdasarkan kata kunci
//  - initialStatus  -> langsung filter berdasarkan status
// ─────────────────────────────────────────────────────────────────────────────

class ListRequestPage extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  final String? initialQuery;
  final String? initialStatus;
  final bool autoFocusSearch;

  const ListRequestPage({
    super.key,
    required this.requests,
    this.initialQuery,
    this.initialStatus,
    this.autoFocusSearch = false,
  });

  @override
  State<ListRequestPage> createState() => _ListRequestPageState();
}

class _ListRequestPageState extends State<ListRequestPage> {
  late final TextEditingController _searchCtrl;
  late final FocusNode _searchFocus;

  String _query = '';
  String _status = 'all';
  String _sort = 'newest';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _status = widget.initialStatus ?? 'all';
    _searchCtrl = TextEditingController(text: _query);
    _searchFocus = FocusNode();
    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    var list = widget.requests.where((r) {
      if (_status != 'all' && r['status'] != _status) return false;
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      final item = (r['item'] ?? '').toString().toLowerCase();
      final code = (r['code'] ?? '').toString().toLowerCase();
      final notes = (r['notes'] ?? '').toString().toLowerCase();
      return item.contains(q) || code.contains(q) || notes.contains(q);
    }).toList();

    list.sort((a, b) {
      final ai = widget.requests.indexOf(a);
      final bi = widget.requests.indexOf(b);
      return _sort == 'newest' ? ai.compareTo(bi) : bi.compareTo(ai);
    });
    return list;
  }

  int _countByStatus(String s) =>
      widget.requests.where((r) => r['status'] == s).length;

  // ── Buka Chat Admin dengan prefill detail request ─────────────────────────
  void _openChatAdmin(Map<String, dynamic> req) {
    HapticFeedback.selectionClick();
    final meta = _statusMeta(req['status'] as String);
    final notes = (req['notes'] as String?)?.trim() ?? '';

    final buffer = StringBuffer()
      ..writeln('Halo Pak Admin, saya mau menanyakan request berikut:')
      ..writeln()
      ..writeln('📦 Barang   : ${req['item']}')
      ..writeln('🔖 Kode     : ${req['code']}')
      ..writeln('🔢 Jumlah   : ${req['qty']} ${req['unit'] ?? 'unit'}')
      ..writeln('📅 Tanggal  : ${req['date']}')
      ..writeln('👤 Approver : ${req['approver']}')
      ..writeln('📌 Status   : ${meta.label}');
    if (notes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Catatan: $notes');
    }
    buffer
      ..writeln()
      ..write('Mohon info update terbaru. Terima kasih.');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailChatPage(
          prefillMessage: buffer.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightOverlay,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: _buildSearchField(),
              ),
            ),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(child: _buildResultHeader(results.length)),
            results.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmpty(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    sliver: SliverList.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildRequestCard(results[i]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
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
                  padding: const EdgeInsets.fromLTRB(60, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Semua Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.requests.length} request total · cari & filter di bawah',
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

  // ── Search ────────────────────────────────────────────────────────────────
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama barang, kode, atau catatan...',
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded,
                size: 20, color: AppTheme.primary),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'Semua', 'count': widget.requests.length},
      {
        'value': 'pending',
        'label': 'Pending',
        'count': _countByStatus('pending'),
        'color': AppTheme.statusPending,
      },
      {
        'value': 'approved',
        'label': 'Disetujui',
        'count': _countByStatus('approved'),
        'color': AppTheme.statusApproved,
      },
      {
        'value': 'rejected',
        'label': 'Ditolak',
        'count': _countByStatus('rejected'),
        'color': AppTheme.statusRejected,
      },
      {
        'value': 'completed',
        'label': 'Selesai',
        'count': _countByStatus('completed'),
        'color': AppTheme.statusCompleted,
      },
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = _status == f['value'];
          final accent = (f['color'] as Color?) ?? AppTheme.primary;
          return GestureDetector(
            onTap: () => setState(() => _status = f['value'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    f['label'] as String,
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
                      '${f['count']}',
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

  // ── Result Header (count + sort) ──────────────────────────────────────────
  Widget _buildResultHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            '$count hasil',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(
                () => _sort = _sort == 'newest' ? 'oldest' : 'newest'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sort == 'newest'
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sort == 'newest' ? 'Terbaru' : 'Terlama',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 36, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada request ditemukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba ubah kata kunci atau filter status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Request Card ──────────────────────────────────────────────────────────
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = req['status'] as String;
    final meta = _statusMeta(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      req['code'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: meta.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          Row(
            children: [
              _detailItem(
                  Icons.inventory_2_outlined,
                  'Jumlah',
                  '${req['qty']} ${req['unit'] ?? 'unit'}'),
              const SizedBox(width: 12),
              _detailItem(Icons.calendar_today_outlined, 'Tanggal',
                  req['date'] as String),
              const SizedBox(width: 12),
              _detailItem(Icons.person_outline_rounded, 'Approver',
                  req['approver'] as String),
            ],
          ),
          if ((req['notes'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 13, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      req['notes'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          // Tombol Chat Admin
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openChatAdmin(req),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Chat Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'tanya request ini',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
