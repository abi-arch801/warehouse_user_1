import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Stok Kritis: Headset Sony',
      'body': 'Stok Headset Sony WH-1000XM5 hanya tersisa 3 unit. Segera lakukan restok.',
      'time': '5 menit lalu',
      'type': 'alert',
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFFF7043),
      'bgColor': Color(0xFFFFF3E0),
      'read': false,
    },
    {
      'title': 'Barang Masuk Berhasil',
      'body': '25 unit Laptop Acer Aspire 5 telah berhasil dicatat masuk ke gudang oleh Ahmad Fauzi.',
      'time': '10 menit lalu',
      'type': 'success',
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF00BFA5),
      'bgColor': Color(0xFFE0F7FA),
      'read': false,
    },
    {
      'title': 'Laporan Mingguan Tersedia',
      'body': 'Laporan aktivitas gudang minggu ini sudah dapat diunduh. Periode: 13–19 April 2026.',
      'time': '1 jam lalu',
      'type': 'info',
      'icon': Icons.bar_chart_rounded,
      'color': Color(0xFF0288D1),
      'bgColor': Color(0xFFE1F5FE),
      'read': false,
    },
    {
      'title': 'Permintaan Restok Disetujui',
      'body': 'Permintaan restok 100 unit Mouse Wireless Logitech telah disetujui oleh Supervisor.',
      'time': '2 jam lalu',
      'type': 'success',
      'icon': Icons.thumb_up_rounded,
      'color': Color(0xFF00BFA5),
      'bgColor': Color(0xFFE0F7FA),
      'read': true,
    },
    {
      'title': 'Pengiriman Dalam Perjalanan',
      'body': 'Pengiriman barang ke Cabang Surabaya telah berangkat. Estimasi tiba: 21 April 2026.',
      'time': '3 jam lalu',
      'type': 'shipping',
      'icon': Icons.local_shipping_rounded,
      'color': Color(0xFF7B1FA2),
      'bgColor': Color(0xFFF3E5F5),
      'read': true,
    },
    {
      'title': 'Login Baru Terdeteksi',
      'body': 'Login baru ke akun Anda dari perangkat baru. Jika bukan Anda, segera ubah kata sandi.',
      'time': 'Kemarin, 17:40',
      'type': 'security',
      'icon': Icons.security_rounded,
      'color': Color(0xFFFFB300),
      'bgColor': Color(0xFFFFF8E1),
      'read': true,
    },
    {
      'title': 'Stok Kritis: Keyboard RGB',
      'body': 'Stok Keyboard Mechanical RGB hanya tersisa 5 unit. Segera lakukan restok.',
      'time': 'Kemarin, 14:22',
      'type': 'alert',
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFFF7043),
      'bgColor': Color(0xFFFFF3E0),
      'read': true,
    },
    {
      'title': 'Pembaruan Sistem',
      'body': 'GudangPro diperbarui ke versi 1.0.1. Beberapa peningkatan performa dan perbaikan bug telah dilakukan.',
      'time': '2 hari lalu',
      'type': 'system',
      'icon': Icons.system_update_rounded,
      'color': Color(0xFF546E7A),
      'bgColor': Color(0xFFECEFF1),
      'read': true,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !(n['read'] as bool)).length;

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

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0288D1),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (_unreadCount > 0)
                Text(
                  '$_unreadCount belum dibaca',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
            ],
          ),
          actions: [
            if (_unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                child: const Text(
                  'Tandai dibaca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _notifications.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildSectionHeader('Terbaru');
            }
            final n = _notifications[index - 1];

            // Add section headers
            if (index == 4) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Sebelumnya'),
                  _buildNotificationItem(n),
                ],
              );
            }

            return _buildNotificationItem(n);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0277BD),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n) {
    final isUnread = !(n['read'] as bool);

    return GestureDetector(
      onTap: () {
        setState(() => n['read'] = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? (n['color'] as Color).withOpacity(0.2)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: (n['color'] as Color).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: n['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  n['icon'] as IconData,
                  color: n['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: BoxDecoration(
                              color: n['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n['body'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnread
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          n['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
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
