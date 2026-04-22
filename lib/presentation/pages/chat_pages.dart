import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_user_1/presentation/pages/detail_chat_pages.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat Page (List Pesan) — GudangPro IPAL
//
// Perbaikan dari versi awal:
//  • Pakai AppTheme (primary, primaryGradient, statusApproved, dll) — bukan
//    hardcoded biru 0xFF0288D1.
//  • Tab filter (Semua / Belum Dibaca / Grup) benar-benar memfilter list.
//  • Tap kontak chat → buka DetailChatPage.
//  • Tombol Tulis Pesan baru, Edit, & More menu fungsional (popup info).
//  • Konteks divisi IPAL: nama, role, dan isi pesan disesuaikan dengan
//    operasional gudang IPAL (water-treatment).
//  • Empty state untuk tab "Belum Dibaca" yang kosong.
// ─────────────────────────────────────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  static const _tabs = ['Semua', 'Belum Dibaca', 'Grup'];

  // Daftar chat — disesuaikan ke konteks gudang IPAL.
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Ahmad Fauzi',
      'role': 'Admin Gudang IPAL',
      'message':
          'Stok pompa submersible 1HP masih ada 3 unit pak, silakan ajukan request.',
      'time': '10:32',
      'unread': 2,
      'online': true,
      'isGroup': false,
      'initials': 'AF',
      'color': AppTheme.primary,
    },
    {
      'name': 'Siti Rahayu',
      'role': 'Supervisor IPAL',
      'message': 'Laporan harian kualitas air sudah saya kirim via email.',
      'time': '09:15',
      'unread': 0,
      'online': true,
      'isGroup': false,
      'initials': 'SR',
      'color': const Color(0xFF7B1FA2),
    },
    {
      'name': 'Tim Operator IPAL',
      'role': 'Grup · 8 anggota',
      'message': 'Budi: Shift sore siap bertugas, semua pompa normal!',
      'time': 'Kemarin',
      'unread': 5,
      'online': false,
      'isGroup': true,
      'initials': 'TO',
      'color': const Color(0xFF00BFA5),
    },
    {
      'name': 'Budi Santoso',
      'role': 'Driver Logistik',
      'message': 'Pengiriman bahan kimia ke IPAL Cabang sudah berangkat.',
      'time': 'Kemarin',
      'unread': 0,
      'online': false,
      'isGroup': false,
      'initials': 'BS',
      'color': const Color(0xFFFF7043),
    },
    {
      'name': 'Dewi Lestari',
      'role': 'Admin Keuangan',
      'message': 'Invoice pembelian membran filter sudah diproses.',
      'time': 'Sen',
      'unread': 0,
      'online': false,
      'isGroup': false,
      'initials': 'DL',
      'color': const Color(0xFFFFB300),
    },
    {
      'name': 'Gudang Pusat IPAL',
      'role': 'Grup · 12 anggota',
      'message':
          'Admin: Rapat koordinasi maintenance bulanan besok jam 09.00.',
      'time': 'Min',
      'unread': 1,
      'online': false,
      'isGroup': true,
      'initials': 'GP',
      'color': AppTheme.primaryDark,
    },
    {
      'name': 'Reza Permana',
      'role': 'Kepala Gudang IPAL',
      'message': 'Oke, siap dilaporkan minggu depan setelah audit stok.',
      'time': '20/04',
      'unread': 0,
      'online': true,
      'isGroup': false,
      'initials': 'RP',
      'color': const Color(0xFF00897B),
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    Iterable<Map<String, dynamic>> list = _chats;

    // Filter tab
    if (_selectedTab == 1) {
      list = list.where((c) => (c['unread'] as int) > 0);
    } else if (_selectedTab == 2) {
      list = list.where((c) => (c['isGroup'] as bool) == true);
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
          (c['name'] as String).toLowerCase().contains(q) ||
          (c['message'] as String).toLowerCase().contains(q) ||
          (c['role'] as String).toLowerCase().contains(q));
    }

    return list.toList();
  }

  int get _totalUnread =>
      _chats.fold(0, (sum, c) => sum + (c['unread'] as int));

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Map<String, dynamic> chat) {
    // Saat ini DetailChatPage membuka chat dengan admin default (Ahmad Fauzi).
    // Kalau nanti ingin per-kontak, tinggal kirim parameter ke DetailChatPage.
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DetailChatPage()),
    );
  }

  void _showInDevelopment(String featureName) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: Text(
          'Fitur "$featureName" sedang dalam tahap pengembangan dan akan '
          'segera tersedia di update berikutnya.',
          style: const TextStyle(fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            _menuTile(Icons.mark_chat_read_rounded, 'Tandai Semua Dibaca',
                () {
              Navigator.pop(context);
              setState(() {
                for (final c in _chats) {
                  c['unread'] = 0;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua pesan ditandai sudah dibaca'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }),
            _menuTile(Icons.archive_rounded, 'Pesan Diarsipkan', () {
              Navigator.pop(context);
              _showInDevelopment('Pesan Diarsipkan');
            }),
            _menuTile(Icons.notifications_off_rounded, 'Notifikasi', () {
              Navigator.pop(context);
              _showInDevelopment('Pengaturan Notifikasi');
            }),
            _menuTile(Icons.settings_rounded, 'Pengaturan Pesan', () {
              Navigator.pop(context);
              _showInDevelopment('Pengaturan Pesan');
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 19),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey.shade400, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildChatList()),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showInDevelopment('Pesan Baru'),
            backgroundColor: AppTheme.primary,
            elevation: 4,
            icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
            label: const Text(
              'Tulis Pesan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Text(
            'Pesan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (_totalUnread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_totalUnread baru',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_square,
              color: Colors.white, size: 21),
          onPressed: () => _showInDevelopment('Edit Daftar Chat'),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: Colors.white, size: 22),
          onPressed: _openMoreMenu,
        ),
      ],
    );
  }

  // ── Header (search + tabs) ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Cari pesan atau kontak...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.8), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_tabs.length, (i) {
              final isSelected = _selectedTab == i;
              final label = _tabs[i];
              int? badge;
              if (i == 1) badge = _totalUnread;
              if (i == 2) {
                badge = _chats.where((c) => c['isGroup'] as bool).length;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.white,
                          ),
                        ),
                        if (badge != null && badge > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$badge',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Chat List ─────────────────────────────────────────────────────────────
  Widget _buildChatList() {
    final list = _filteredChats;
    return Container(
      color: Colors.white,
      child: list.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
                indent: 76,
              ),
              itemBuilder: (_, i) => _buildChatItem(list[i]),
            ),
    );
  }

  Widget _buildEmptyState() {
    String label;
    String hint;
    IconData icon;
    if (_searchQuery.isNotEmpty) {
      icon = Icons.search_off_rounded;
      label = 'Tidak ada hasil';
      hint = 'Coba kata kunci lain';
    } else if (_selectedTab == 1) {
      icon = Icons.mark_chat_read_rounded;
      label = 'Semua pesan sudah dibaca';
      hint = 'Mantap! Tidak ada pesan tertinggal.';
    } else if (_selectedTab == 2) {
      icon = Icons.groups_rounded;
      label = 'Belum ada grup';
      hint = 'Bergabunglah dengan grup operator IPAL.';
    } else {
      icon = Icons.chat_bubble_outline_rounded;
      label = 'Belum ada pesan';
      hint = 'Mulai chat dengan admin gudang.';
    }

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
              child: Icon(icon, size: 42, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
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

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final hasUnread = (chat['unread'] as int) > 0;

    return InkWell(
      onTap: () => _openChat(chat),
      splashColor: AppTheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (chat['color'] as Color).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chat['initials'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (chat['online'] as bool)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppTheme.statusApproved,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                if (chat['isGroup'] as bool)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.groups_rounded,
                          size: 11, color: AppTheme.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat['time'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: hasUnread
                              ? AppTheme.primary
                              : Colors.grey.shade400,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat['role'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.primary.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: hasUnread
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${chat['unread']}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
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
}
