import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Detail Chat Page — Chat dengan Admin Gudang
//
// Fitur:
//  • Header: avatar + nama + status online + tombol telepon, video call,
//    dan menu titik 3.
//  • Telepon / Video / item drawer → popup "Sedang dalam tahap pengembangan".
//  • Titik 3 → buka end drawer berisi Info, Media, Tautan.
//  • Bubble chat dengan indikator read (✓ terkirim / ✓✓ tersampaikan / 
//    ✓✓ biru sudah dibaca).
//  • Input bawah: tombol attachment (kamera + galeri) untuk upload gambar,
//    text field, dan tombol kirim.
//  • Pakai package: image_picker
// ─────────────────────────────────────────────────────────────────────────────

enum MessageStatus { sent, delivered, read }

class _ChatMessage {
  final String? text;
  final XFile? image;
  final bool fromMe;
  final DateTime time;
  MessageStatus status;

  _ChatMessage({
    this.text,
    this.image,
    required this.fromMe,
    required this.time,
    this.status = MessageStatus.sent,
  });
}

class DetailChatPage extends StatefulWidget {
  /// Pesan yang otomatis diisi di kolom input saat halaman dibuka.
  /// Berguna saat membuka chat dari kartu request — pesan berisi
  /// detail request yang akan ditanyakan.
  final String? prefillMessage;

  const DetailChatPage({super.key, this.prefillMessage});

  @override
  State<DetailChatPage> createState() => _DetailChatPageState();
}

class _DetailChatPageState extends State<DetailChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Data dummy admin & chat ───────────────────────────────────────────────
  static const _adminName = 'Ahmad Fauzi';
  static const _adminRole = 'Admin Gudang IPAL';
  static const _adminInitials = 'AF';

  late List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _messages = [
      _ChatMessage(
        text:
            'Selamat pagi pak, ada yang bisa saya bantu terkait request barang?',
        fromMe: false,
        time: now.subtract(const Duration(minutes: 32)),
      ),
      _ChatMessage(
        text: 'Pagi pak Ahmad, saya mau tanya soal pompa submersible 1 HP.',
        fromMe: true,
        time: now.subtract(const Duration(minutes: 28)),
        status: MessageStatus.read,
      ),
      _ChatMessage(
        text: 'Apakah masih tersedia di gudang? Saya butuh untuk pengganti '
            'pompa inlet yang sudah rusak.',
        fromMe: true,
        time: now.subtract(const Duration(minutes: 27)),
        status: MessageStatus.read,
      ),
      _ChatMessage(
        text: 'Kebetulan stok ada 3 unit pak. Silakan ajukan request via '
            'aplikasi, nanti saya proses cepat.',
        fromMe: false,
        time: now.subtract(const Duration(minutes: 25)),
      ),
      _ChatMessage(
        text: 'Baik pak, terima kasih banyak.',
        fromMe: true,
        time: now.subtract(const Duration(minutes: 22)),
        status: MessageStatus.delivered,
      ),
    ];

    // Prefill input bila ada pesan otomatis (misalnya dari kartu request).
    if (widget.prefillMessage != null && widget.prefillMessage!.isNotEmpty) {
      _textCtrl.text = widget.prefillMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Detail request sudah disiapkan di kolom pesan. '
              'Silakan tinjau lalu kirim.',
              style: TextStyle(fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send({String? text, XFile? image}) {
    if ((text == null || text.trim().isEmpty) && image == null) return;
    HapticFeedback.lightImpact();
    final msg = _ChatMessage(
      text: text?.trim(),
      image: image,
      fromMe: true,
      time: DateTime.now(),
      status: MessageStatus.sent,
    );
    setState(() {
      _messages.add(msg);
      _textCtrl.clear();
    });
    _scrollToBottom();

    // Simulasi: ✓ → ✓✓ → ✓✓ biru
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => msg.status = MessageStatus.delivered);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => msg.status = MessageStatus.read);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // tutup bottom sheet attach
    try {
      final img = await _picker.pickImage(source: source, imageQuality: 80);
      if (img != null) _send(image: img);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka: $e')),
      );
    }
  }

  void _showAttachSheet() {
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
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kirim Lampiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _attachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: AppTheme.primary,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 12),
                _attachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  color: const Color(0xFF7B1FA2),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Popup "dalam tahap pengembangan" ──────────────────────────────────────
  void _showInDevelopmentPopup(String featureName) {
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
              child: Text(
                'Sedang Dikembangkan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
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
            child: const Text(
              'Mengerti',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightOverlay,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: _buildAppBar(),
        endDrawer: _buildEndDrawer(),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _buildBubble(_messages[i]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      ),
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      leadingWidth: 44,
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  _adminInitials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppTheme.statusApproved,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  _adminName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.statusApproved,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online · $_adminRole',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.white.withOpacity(0.9),
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
      actions: [
        IconButton(
          tooltip: 'Telepon',
          icon: const Icon(Icons.call_rounded, size: 22, color: Colors.white),
          onPressed: () => _showInDevelopmentPopup('Panggilan Telepon'),
        ),
        IconButton(
          tooltip: 'Video Call',
          icon: const Icon(Icons.videocam_rounded,
              size: 24, color: Colors.white),
          onPressed: () => _showInDevelopmentPopup('Video Call'),
        ),
        IconButton(
          tooltip: 'Menu',
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  // ── End Drawer (Info, Media, Tautan) ──────────────────────────────────────
  Widget _buildEndDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      _adminInitials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    _adminName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _adminRole,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(
              icon: Icons.info_outline_rounded,
              color: AppTheme.primary,
              title: 'Info',
              subtitle: 'Detail kontak & profil admin',
              onTap: () {
                Navigator.pop(context);
                _showInDevelopmentPopup('Info Kontak');
              },
            ),
            _drawerItem(
              icon: Icons.photo_library_rounded,
              color: const Color(0xFF7B1FA2),
              title: 'Media',
              subtitle: 'Foto & file yang dibagikan',
              onTap: () {
                Navigator.pop(context);
                _showInDevelopmentPopup('Media');
              },
            ),
            _drawerItem(
              icon: Icons.link_rounded,
              color: const Color(0xFFFF7043),
              title: 'Tautan',
              subtitle: 'Tautan yang pernah dibagikan',
              onTap: () {
                Navigator.pop(context);
                _showInDevelopmentPopup('Tautan');
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'GudangPro · Chat Admin',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey.shade400, size: 22),
    );
  }

  // ── Bubble Chat ───────────────────────────────────────────────────────────
  Widget _buildBubble(_ChatMessage msg) {
    final me = msg.fromMe;
    final bg = me ? AppTheme.primary : Colors.white;
    final fg = me ? Colors.white : AppTheme.textPrimary;
    final align = me ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            me ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!me) _avatarSmall(),
          if (!me) const SizedBox(width: 6),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(me ? 16 : 4),
                      bottomRight: Radius.circular(me ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: msg.image != null
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.fromLTRB(13, 9, 13, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (msg.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(msg.image!.path),
                            width: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (msg.text != null && msg.text!.isNotEmpty)
                        Padding(
                          padding: msg.image != null
                              ? const EdgeInsets.fromLTRB(8, 6, 8, 6)
                              : EdgeInsets.zero,
                          child: Text(
                            msg.text!,
                            style: TextStyle(
                              fontSize: 13,
                              color: fg,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.time),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (me) ...[
                        const SizedBox(width: 4),
                        _readIcon(msg.status),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarSmall() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        _adminInitials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _readIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check_rounded,
            size: 13, color: Colors.grey.shade500);
      case MessageStatus.delivered:
        return Icon(Icons.done_all_rounded,
            size: 13, color: Colors.grey.shade500);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 13, color: AppTheme.primary);
    }
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Attachment
            GestureDetector(
              onTap: _showAttachSheet,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.attach_file_rounded,
                    color: AppTheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Text Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                        ),
                        onSubmitted: (v) => _send(text: v),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt_rounded,
                          color: Colors.grey.shade500, size: 20),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send
            GestureDetector(
              onTap: () => _send(text: _textCtrl.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
