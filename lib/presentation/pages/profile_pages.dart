import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Edit Profil',
      'subtitle': 'Ubah informasi akun Anda',
      'icon': Icons.person_outline_rounded,
      'color': Color(0xFF0288D1),
    },
    {
      'title': 'Manajemen Gudang',
      'subtitle': 'Kelola akses dan lokasi gudang',
      'icon': Icons.warehouse_outlined,
      'color': Color(0xFF00BFA5),
    },
    {
      'title': 'Pengguna & Akses',
      'subtitle': 'Kelola akun staff dan hak akses',
      'icon': Icons.group_outlined,
      'color': Color(0xFF7B1FA2),
    },
    {
      'title': 'Laporan & Ekspor',
      'subtitle': 'Unduh laporan dalam format PDF/Excel',
      'icon': Icons.summarize_outlined,
      'color': Color(0xFFFF7043),
    },
    {
      'title': 'Integrasi Sistem',
      'subtitle': 'Hubungkan dengan ERP atau marketplace',
      'icon': Icons.integration_instructions_outlined,
      'color': Color(0xFFFFB300),
    },
    {
      'title': 'Bantuan & Dukungan',
      'subtitle': 'FAQ, panduan, dan kontak support',
      'icon': Icons.help_outline_rounded,
      'color': Color(0xFF546E7A),
    },
    {
      'title': 'Tentang Aplikasi',
      'subtitle': 'GudangPro v1.0.0',
      'icon': Icons.info_outline_rounded,
      'color': Color(0xFF546E7A),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Akun?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF01579B),
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
                style: TextStyle(color: Color(0xFF0288D1))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Profile header
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0288D1),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0277BD),
                        Color(0xFF0288D1),
                        Color(0xFF29B6F6),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Avatar
                        Stack(
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
                              child: const Center(
                                child: Text(
                                  'AD',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0288D1),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00BFA5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Admin Gudang',
                          style: TextStyle(
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
                          child: const Text(
                            'admin@gudangpro.id  •  Super Admin',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProfileStat('3', 'Gudang'),
                            Container(
                                height: 28,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20)),
                            _buildProfileStat('12', 'Staff'),
                            Container(
                                height: 28,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20)),
                            _buildProfileStat('847', 'Transaksi'),
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
                  onPressed: () {},
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pengaturan Notifikasi
                    _buildSectionTitle('Pengaturan Notifikasi'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0288D1).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.notifications_rounded,
                            color: const Color(0xFF0288D1),
                            title: 'Notifikasi Push',
                            subtitle: 'Terima notifikasi langsung di perangkat',
                            value: _notifPush,
                            onChanged: (val) =>
                                setState(() => _notifPush = val),
                            isFirst: true,
                            isLast: false,
                          ),
                          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                          _buildToggleTile(
                            icon: Icons.email_rounded,
                            color: const Color(0xFF00BFA5),
                            title: 'Notifikasi Email',
                            subtitle: 'Terima ringkasan harian via email',
                            value: _notifEmail,
                            onChanged: (val) =>
                                setState(() => _notifEmail = val),
                            isFirst: false,
                            isLast: false,
                          ),
                          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
                          _buildToggleTile(
                            icon: Icons.fingerprint_rounded,
                            color: const Color(0xFF7B1FA2),
                            title: 'Login Biometrik',
                            subtitle: 'Gunakan sidik jari atau face ID',
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
                            color: const Color(0xFF0288D1).withOpacity(0.08),
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
                          backgroundColor: const Color(0xFFFF5252).withOpacity(0.1),
                          foregroundColor: const Color(0xFFFF5252),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFFFF5252),
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
        color: Color(0xFF0277BD),
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
                    color: Color(0xFF01579B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0288D1),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF0288D1).withOpacity(0.3);
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
  }) {
    return InkWell(
      onTap: () {},
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
                      color: Color(0xFF01579B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
