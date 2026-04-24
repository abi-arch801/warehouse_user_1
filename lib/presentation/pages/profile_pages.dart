import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _notifPush = true;
  bool _notifEmail = false;
  bool _biometric = true;

  // ── Status pengajuan role admin ────────────────────────────────────────────
  // 'none'      -> belum pernah mengajukan
  // 'pending'   -> sudah dikirim, menunggu review
  // 'approved'  -> disetujui, user bisa beralih ke mode admin
  // 'rejected'  -> ditolak, bisa mengajukan ulang
  String _adminRequestStatus = 'none';
  DateTime? _adminRequestDate;
  String? _adminRequestReason;
  String? _adminRejectReason;

  // ── Data user (bukan admin) ────────────────────────────────────────────────
  String _userName = 'Bagas Pratama';
  String _userPhone = '+62 812-3456-7890';
  String _userAddress = 'Jl. Melati No. 27, Bandung, Jawa Barat';
  String _userOffice = 'PT. Tirta Aquatech Mandiri';
  String _userPosition = 'Operator IPAL';
  final String _userEmail = 'bagas.pratama@tirta-aquatech.id';

  String get _initials {
    final parts = _userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  final List<Map<String, dynamic>> _menuItems = const [
    {
      'title': 'Edit Profil',
      'subtitle': 'Ubah informasi akun Anda',
      'icon': Icons.person_outline_rounded,
      'color': AppTheme.primary,
      'key': 'edit',
    },
    {
      'title': 'Riwayat Permintaan',
      'subtitle': 'Lihat semua permintaan barang Anda',
      'icon': Icons.receipt_long_rounded,
      'color': AppTheme.statusApproved,
      'key': 'history',
    },
    {
      'title': 'Notifikasi Saya',
      'subtitle': 'Kelola notifikasi & pengingat',
      'icon': Icons.notifications_active_outlined,
      'color': AppTheme.statusPending,
      'key': 'notif',
    },
    {
      'title': 'Keamanan Akun',
      'subtitle': 'Ubah password & verifikasi',
      'icon': Icons.lock_outline_rounded,
      'color': AppTheme.primaryLight,
      'key': 'security',
    },
    {
      'title': 'Bantuan & Dukungan',
      'subtitle': 'FAQ, panduan, dan kontak support',
      'icon': Icons.help_outline_rounded,
      'color': Color(0xFF546E7A),
      'key': 'help',
    },
    {
      'title': 'Tentang Aplikasi',
      'subtitle': 'GudangPro v1.0.0',
      'icon': Icons.info_outline_rounded,
      'color': Color(0xFF546E7A),
      'key': 'about',
    },
  ];

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

  // ─── Pop-up: Sedang Dalam Pengembangan ─────────────────────────────────────
  void _showInDevelopmentDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sedang Dalam Tahap Pengembangan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fitur "$featureName" akan segera tersedia di pembaruan berikutnya. Terima kasih atas kesabaran Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pop-up: Edit Profile (setengah layar) ─────────────────────────────────
  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final addressCtrl = TextEditingController(text: _userAddress);
    final officeCtrl = TextEditingController(text: _userOffice);
    final positionCtrl = TextEditingController(text: _userPosition);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  // form
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      children: [
                        // Avatar uploader
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _initials,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Pilih foto dari galeri (demo).'),
                                        backgroundColor: AppTheme.primary,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppTheme.statusApproved,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unggah foto profil (demo).'),
                                  backgroundColor: AppTheme.primary,
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload_rounded,
                                size: 16, color: AppTheme.primary),
                            label: const Text(
                              'Unggah Foto Profil',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: nameCtrl,
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: phoneCtrl,
                          label: 'Nomor Telepon',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: addressCtrl,
                          label: 'Alamat',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: officeCtrl,
                          label: 'Kantor / Perusahaan',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: positionCtrl,
                          label: 'Posisi / Jabatan',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _userName = nameCtrl.text.trim();
                                _userPhone = phoneCtrl.text.trim();
                                _userAddress = addressCtrl.text.trim();
                                _userOffice = officeCtrl.text.trim();
                                _userPosition = positionCtrl.text.trim();
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil berhasil diperbarui.'),
                                  backgroundColor: AppTheme.statusApproved,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Akun?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari GudangPro?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(Map<String, dynamic> item) {
    final key = item['key'] as String;
    if (key == 'edit') {
      _showEditProfileSheet();
      return;
    }
    _showInDevelopmentDialog(item['title'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Profile header
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration:
                      const BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Avatar (tap = open edit profile sheet)
                        GestureDetector(
                          onTap: _showEditProfileSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _initials,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusApproved,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_userPosition  •  $_userOffice',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Stats row (user-centric)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProfileStat('24', 'Permintaan'),
                            Container(
                                height: 28,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20)),
                            _buildProfileStat('19', 'Disetujui'),
                            Container(
                                height: 28,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20)),
                            _buildProfileStat('3', 'Pending'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => _showInDevelopmentDialog('Pengaturan'),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Akses & Peran (Pengajuan jadi Admin) ──────────────
                    _buildSectionTitle('Akses & Peran'),
                    const SizedBox(height: 10),
                    _buildAdminRequestCard(),

                    const SizedBox(height: 20),

                    // Pengaturan Notifikasi
                    _buildSectionTitle('Preferensi Akun'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.notifications_rounded,
                            color: AppTheme.primary,
                            title: 'Notifikasi Push',
                            subtitle:
                                'Terima notifikasi langsung di perangkat',
                            value: _notifPush,
                            onChanged: (val) =>
                                setState(() => _notifPush = val),
                            isFirst: true,
                            isLast: false,
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          _buildToggleTile(
                            icon: Icons.email_rounded,
                            color: AppTheme.statusApproved,
                            title: 'Notifikasi Email',
                            subtitle:
                                'Terima ringkasan harian via email',
                            value: _notifEmail,
                            onChanged: (val) =>
                                setState(() => _notifEmail = val),
                            isFirst: false,
                            isLast: false,
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          _buildToggleTile(
                            icon: Icons.fingerprint_rounded,
                            color: AppTheme.primaryLight,
                            title: 'Login Biometrik',
                            subtitle:
                                'Gunakan sidik jari atau face ID',
                            value: _biometric,
                            onChanged: (val) =>
                                setState(() => _biometric = val),
                            isFirst: false,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Menu settings
                    _buildSectionTitle('Pengaturan & Bantuan'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _menuItems.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          return Column(
                            children: [
                              _buildMenuTile(
                                icon: item['icon'] as IconData,
                                color: item['color'] as Color,
                                title: item['title'] as String,
                                subtitle: item['subtitle'] as String,
                                isFirst: index == 0,
                                isLast: index == _menuItems.length - 1,
                                onTap: () => _handleMenuTap(item),
                              ),
                              if (index < _menuItems.length - 1)
                                Divider(
                                  height: 1,
                                  color: Colors.grey.shade100,
                                  indent: 60,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.statusRejected.withOpacity(0.1),
                          foregroundColor: AppTheme.statusRejected,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppTheme.statusRejected,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'GudangPro v1.0.0  •  © 2026',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryDark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primary.withOpacity(0.3);
              }
              return Colors.grey.shade200;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ── ADMIN ROLE REQUEST ────────────────────────────────────────────────────
  // ───────────────────────────────────────────────────────────────────────────

  // Format tanggal singkat: "24 Apr 2026"
  String _formatShortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  // Kartu utama yang berubah tampilan sesuai status pengajuan.
  Widget _buildAdminRequestCard() {
    switch (_adminRequestStatus) {
      case 'pending':
        return _buildAdminCardPending();
      case 'approved':
        return _buildAdminCardApproved();
      case 'rejected':
        return _buildAdminCardRejected();
      case 'none':
      default:
        return _buildAdminCardNone();
    }
  }

  // ── State: belum pernah mengajukan ────────────────────────────────────────
  Widget _buildAdminCardNone() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran di pojok
          Positioned(
            right: -22,
            top: -22,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -28,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tingkatkan ke Admin',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelola gudang & setujui permintaan tim',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      _AdminPerk(
                          icon: Icons.verified_user_rounded,
                          text: 'Menyetujui / menolak permintaan barang'),
                      SizedBox(height: 6),
                      _AdminPerk(
                          icon: Icons.inventory_rounded,
                          text: 'Mengelola stok & katalog gudang'),
                      SizedBox(height: 6),
                      _AdminPerk(
                          icon: Icons.insights_rounded,
                          text: 'Melihat laporan & statistik penuh'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _showAdminRequestSheet,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      'Ajukan Sekarang',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── State: sedang menunggu review ─────────────────────────────────────────
  Widget _buildAdminCardPending() {
    final dateStr = _adminRequestDate != null
        ? _formatShortDate(_adminRequestDate!)
        : '-';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.statusPending.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.statusPending.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.statusPending.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppTheme.statusPending,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengajuan Admin Sedang Ditinjau',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diajukan pada $dateStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusPending,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimasi review 1–3 hari kerja oleh tim Super Admin. Anda akan mendapatkan notifikasi saat keputusan keluar.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAdminRequestDetailSheet,
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                        color: AppTheme.primary.withOpacity(0.5),
                        width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmCancelAdminRequest,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text(
                    'Batalkan',
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.statusRejected.withOpacity(0.1),
                    foregroundColor: AppTheme.statusRejected,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      side: BorderSide(
                          color:
                              AppTheme.statusRejected.withOpacity(0.4),
                          width: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── State: pengajuan disetujui ────────────────────────────────────────────
  Widget _buildAdminCardApproved() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.statusApproved.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.statusApproved.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.statusApproved.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppTheme.statusApproved,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pengajuan Admin Disetujui',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Anda kini memiliki akses ke mode Admin.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.statusApproved,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showInDevelopmentDialog('Mode Admin'),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text(
                'Beralih ke Mode Admin',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusApproved,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── State: pengajuan ditolak ──────────────────────────────────────────────
  Widget _buildAdminCardRejected() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.statusRejected.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.statusRejected.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.statusRejected.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: AppTheme.statusRejected,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pengajuan Admin Ditolak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Anda dapat mengajukan kembali setelah memenuhi syarat.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.statusRejected,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((_adminRejectReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.statusRejected.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.statusRejected.withOpacity(0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: AppTheme.statusRejected),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alasan penolakan: ${_adminRejectReason!}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _showAdminRequestSheet,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Ajukan Ulang',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet: form pengajuan jadi admin ───────────────────────────────
  void _showAdminRequestSheet() {
    final formKey = GlobalKey<FormState>();
    final reasonCtrl = TextEditingController(text: _adminRequestReason ?? '');
    final experienceCtrl = TextEditingController();
    final divisionCtrl = TextEditingController(text: _userOffice);
    final supervisorCtrl = TextEditingController();
    bool agreement = false;
    String? attachmentLabel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return StatefulBuilder(
              builder: (ctx, setSheet) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 10, bottom: 6),
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 12, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ajukan Sebagai Admin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Lengkapi data berikut untuk ditinjau',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppTheme.primary),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          height: 1, color: Colors.grey.shade100),
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                                20, 16, 20, 20),
                            children: [
                              // Banner penjelasan
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primary.withOpacity(0.06),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary
                                        .withOpacity(0.18),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: const [
                                    Icon(Icons.shield_rounded,
                                        size: 18,
                                        color: AppTheme.primary),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Sebagai admin, Anda akan dapat menyetujui permintaan barang, mengelola stok gudang, dan melihat laporan penuh. Pastikan informasi yang Anda berikan akurat.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppTheme.textPrimary,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Data akun ringkas (read-only)
                              _buildAdminInfoTile(
                                  Icons.person_rounded,
                                  'Nama',
                                  _userName),
                              const SizedBox(height: 8),
                              _buildAdminInfoTile(Icons.email_rounded,
                                  'Email', _userEmail),
                              const SizedBox(height: 8),
                              _buildAdminInfoTile(Icons.badge_rounded,
                                  'Posisi Saat Ini', _userPosition),
                              const SizedBox(height: 18),

                              _buildAdminFieldLabel('Divisi / Departemen'),
                              const SizedBox(height: 6),
                              _buildAdminTextField(
                                controller: divisionCtrl,
                                hint: 'Contoh: Divisi IPAL',
                                icon: Icons.business_rounded,
                                validator: (v) => (v == null ||
                                        v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              _buildAdminFieldLabel(
                                  'Alasan Pengajuan'),
                              const SizedBox(height: 6),
                              _buildAdminTextField(
                                controller: reasonCtrl,
                                hint:
                                    'Jelaskan kenapa Anda perlu akses admin...',
                                icon: Icons.edit_note_rounded,
                                maxLines: 4,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Tolong jelaskan alasan Anda';
                                  }
                                  if (v.trim().length < 20) {
                                    return 'Minimal 20 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              _buildAdminFieldLabel(
                                  'Pengalaman Mengelola Inventory'),
                              const SizedBox(height: 6),
                              _buildAdminTextField(
                                controller: experienceCtrl,
                                hint:
                                    'Contoh: 2 tahun mengelola stok bahan kimia...',
                                icon: Icons.history_edu_rounded,
                                maxLines: 3,
                                validator: (v) => (v == null ||
                                        v.trim().isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              _buildAdminFieldLabel(
                                  'Atasan Langsung (opsional)'),
                              const SizedBox(height: 6),
                              _buildAdminTextField(
                                controller: supervisorCtrl,
                                hint:
                                    'Nama atasan / email rekomendasi',
                                icon: Icons
                                    .supervisor_account_rounded,
                              ),
                              const SizedBox(height: 14),

                              _buildAdminFieldLabel(
                                  'Dokumen Pendukung (opsional)'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  setSheet(() {
                                    attachmentLabel = attachmentLabel ==
                                            null
                                        ? 'SK_Penugasan.pdf'
                                        : null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: attachmentLabel != null
                                        ? AppTheme.primary
                                            .withOpacity(0.06)
                                        : AppTheme.background,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color: attachmentLabel != null
                                          ? AppTheme.primary
                                              .withOpacity(0.4)
                                          : Colors.grey.shade300,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: attachmentLabel != null
                                              ? AppTheme.primary
                                              : AppTheme.primary
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                        ),
                                        child: Icon(
                                          attachmentLabel != null
                                              ? Icons
                                                  .description_rounded
                                              : Icons
                                                  .upload_file_rounded,
                                          color: attachmentLabel != null
                                              ? Colors.white
                                              : AppTheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              attachmentLabel ??
                                                  'Unggah SK / Surat Tugas',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: AppTheme
                                                    .textPrimary,
                                              ),
                                            ),
                                            Text(
                                              attachmentLabel != null
                                                  ? 'Ketuk untuk hapus lampiran'
                                                  : 'Format: PDF / JPG, maks 5 MB',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                color: Colors
                                                    .grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        attachmentLabel != null
                                            ? Icons
                                                .check_circle_rounded
                                            : Icons
                                                .chevron_right_rounded,
                                        color: attachmentLabel != null
                                            ? AppTheme.statusApproved
                                            : Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Checkbox persetujuan
                              InkWell(
                                borderRadius:
                                    BorderRadius.circular(10),
                                onTap: () => setSheet(
                                    () => agreement = !agreement),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: agreement,
                                          onChanged: (v) => setSheet(
                                              () => agreement =
                                                  v ?? false),
                                          activeColor:
                                              AppTheme.primary,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Saya menyatakan informasi di atas benar dan bersedia mengikuti aturan sebagai admin GudangPro.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.grey.shade700,
                                            height: 1.5,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (!formKey.currentState!
                                        .validate()) return;
                                    if (!agreement) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Centang persetujuan terlebih dahulu.'),
                                          backgroundColor:
                                              AppTheme.statusRejected,
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(ctx);
                                    _submitAdminRequest(
                                      reason: reasonCtrl.text.trim(),
                                    );
                                  },
                                  icon: const Icon(Icons.send_rounded,
                                      size: 18),
                                  label: const Text(
                                    'Kirim Pengajuan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Batal',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAdminInfoTile(
      IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildAdminTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppTheme.statusRejected, width: 1.5),
        ),
      ),
    );
  }

  // ── Submit pengajuan ──────────────────────────────────────────────────────
  void _submitAdminRequest({required String reason}) {
    setState(() {
      _adminRequestStatus = 'pending';
      _adminRequestDate = DateTime.now();
      _adminRequestReason = reason;
      _adminRejectReason = null;
    });

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.statusApproved.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.statusApproved, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pengajuan Terkirim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pengajuan Anda untuk menjadi admin sedang ditinjau oleh tim Super Admin. Estimasi 1–3 hari kerja.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Konfirmasi batal pengajuan ────────────────────────────────────────────
  void _confirmCancelAdminRequest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Batalkan Pengajuan?',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              fontSize: 16),
        ),
        content: const Text(
          'Pengajuan admin Anda yang sedang berjalan akan ditarik. Anda dapat mengajukan kembali kapan saja.',
          style: TextStyle(fontSize: 13, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak',
                style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _adminRequestStatus = 'none';
                _adminRequestDate = null;
                _adminRequestReason = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengajuan admin telah dibatalkan.'),
                  backgroundColor: AppTheme.statusRejected,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Sheet detail pengajuan yang sedang berjalan ───────────────────────────
  void _showAdminRequestDetailSheet() {
    final dateStr = _adminRequestDate != null
        ? _formatShortDate(_adminRequestDate!)
        : '-';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detail Pengajuan Admin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildAdminInfoTile(Icons.event_rounded,
                  'Tanggal Pengajuan', dateStr),
              const SizedBox(height: 8),
              _buildAdminInfoTile(Icons.business_rounded, 'Divisi',
                  _userOffice),
              const SizedBox(height: 12),
              _buildAdminFieldLabel('Alasan Pengajuan'),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _adminRequestReason ?? '-',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Item perks kecil di kartu "Tingkatkan ke Admin" ─────────────────────────
class _AdminPerk extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AdminPerk({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
