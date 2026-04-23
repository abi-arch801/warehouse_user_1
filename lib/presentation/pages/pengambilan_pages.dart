import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pengambilan Page — Form pengambilan barang (request yang sudah disetujui)
//
// Alur:
//  1) Tampilkan ringkasan request (item, kode, qty, approver).
//  2) User wajib FOTO bukti pengambilan (kamera).
//  3) User wajib AMBIL TITIK LOKASI (GPS).
//  4) User opsional isi catatan tambahan (jumlah aktual diambil, kondisi, dll).
//  5) Tombol "Kirim ke Admin" aktif kalau foto + lokasi sudah lengkap.
//  6) Setelah dikirim → tampil dialog sukses dan pop ke layar sebelumnya.
//
// Dependensi pubspec:
//   image_picker: ^1.1.2
//   geolocator: ^11.0.0
// Permission Android (AndroidManifest.xml):
//   <uses-permission android:name="android.permission.CAMERA"/>
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
// Permission iOS (Info.plist):
//   NSCameraUsageDescription, NSLocationWhenInUseUsageDescription
// ─────────────────────────────────────────────────────────────────────────────

class PengambilanPage extends StatefulWidget {
  final Map<String, dynamic> request;
  const PengambilanPage({super.key, required this.request});

  @override
  State<PengambilanPage> createState() => _PengambilanPageState();
}

class _PengambilanPageState extends State<PengambilanPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteCtrl = TextEditingController();

  XFile? _photo;
  Position? _position;
  String? _addressLabel;
  bool _loadingLocation = false;
  bool _sending = false;

  bool get _canSubmit => _photo != null && _position != null && !_sending;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Foto Bukti ────────────────────────────────────────────────────────────
  Future<void> _takePhoto() async {
    HapticFeedback.selectionClick();
    try {
      final img = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (img != null) setState(() => _photo = img);
    } catch (e) {
      _snack('Tidak bisa membuka kamera: $e', isError: true);
    }
  }

  // ── Ambil Lokasi ──────────────────────────────────────────────────────────
  Future<void> _captureLocation() async {
    if (_loadingLocation) return;
    HapticFeedback.selectionClick();
    setState(() => _loadingLocation = true);

    try {
      // 1. Cek service GPS aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('GPS belum aktif. Aktifkan lokasi di pengaturan HP.',
            isError: true);
        return;
      }

      // 2. Cek & minta permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak. Tidak bisa ambil titik lokasi.',
            isError: true);
        return;
      }

      // 3. Ambil posisi
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      setState(() {
        _position = pos;
        _addressLabel =
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      });
      _snack('Titik lokasi berhasil direkam');
    } catch (e) {
      _snack('Gagal ambil lokasi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ── Kirim ke Admin ────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    setState(() => _sending = true);

    // Simulasi pengiriman ke admin (di backend asli ganti dengan upload file
    // foto ke server + post payload pengambilan).
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _sending = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.bgApproved,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.statusApproved, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'Berhasil Dikirim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bukti pengambilan barang "${widget.request['item']}" '
              'sudah dikirim ke admin gudang. Status request akan diperbarui '
              'setelah admin memverifikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                Navigator.pop(context); // kembali ke list request
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
                elevation: 0,
              ),
              child: const Text('Selesai',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? AppTheme.statusRejected : AppTheme.statusApproved,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestSummary(req),
                    const SizedBox(height: 22),
                    _sectionTitle(
                      icon: Icons.photo_camera_rounded,
                      title: 'Foto Bukti Pengambilan',
                      required: true,
                    ),
                    const SizedBox(height: 10),
                    _buildPhotoPicker(),
                    const SizedBox(height: 22),
                    _sectionTitle(
                      icon: Icons.location_on_rounded,
                      title: 'Titik Lokasi Pengambilan',
                      required: true,
                    ),
                    const SizedBox(height: 10),
                    _buildLocationPicker(),
                    const SizedBox(height: 22),
                    _sectionTitle(
                      icon: Icons.notes_rounded,
                      title: 'Catatan (opsional)',
                      required: false,
                    ),
                    const SizedBox(height: 10),
                    _buildNoteField(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pengambilan Barang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Foto barang & rekam lokasi pengambilan',
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
        ),
      ),
    );
  }

  // ── Ringkasan Request ─────────────────────────────────────────────────────
  Widget _buildRequestSummary(Map<String, dynamic> req) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.statusApproved.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.bgApproved,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.statusApproved, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req['item'] as String,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      req['code'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.bgApproved,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Disetujui',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.statusApproved,
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
              _summaryItem('Jumlah',
                  '${req['qty']} ${req['unit'] ?? 'unit'}'),
              _summaryItem('Tanggal', req['date'] as String),
              _summaryItem('Approver', req['approver'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required bool required,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 5),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.statusRejected,
            ),
          ),
        ],
      ],
    );
  }

  // ── Photo Picker ──────────────────────────────────────────────────────────
  Widget _buildPhotoPicker() {
    if (_photo == null) {
      return GestureDetector(
        onTap: _takePhoto,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.35),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              const Text(
                'Foto Barang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Tap untuk buka kamera',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(_photo!.path),
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black.withOpacity(0.55),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => _photo = null),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.statusApproved,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_rounded, size: 13, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Foto Tersimpan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _takePhoto,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh_rounded,
                        size: 13, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Ulangi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Location Picker ───────────────────────────────────────────────────────
  Widget _buildLocationPicker() {
    final hasLocation = _position != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLocation
              ? AppTheme.statusApproved.withOpacity(0.4)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppTheme.bgApproved
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  hasLocation
                      ? Icons.location_on_rounded
                      : Icons.location_searching_rounded,
                  color: hasLocation
                      ? AppTheme.statusApproved
                      : AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLocation
                          ? 'Lokasi Terekam'
                          : 'Belum ada titik lokasi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: hasLocation
                            ? AppTheme.statusApproved
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _addressLabel ?? 'Tap tombol untuk ambil GPS sekarang',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontFamily: hasLocation ? 'monospace' : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasLocation && _position!.accuracy > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Akurasi: ±${_position!.accuracy.toStringAsFixed(1)} m',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadingLocation ? null : _captureLocation,
              icon: _loadingLocation
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      hasLocation
                          ? Icons.refresh_rounded
                          : Icons.my_location_rounded,
                      size: 16,
                    ),
              label: Text(
                _loadingLocation
                    ? 'Mengambil lokasi...'
                    : hasLocation
                        ? 'Ambil Ulang Lokasi'
                        : 'Ambil Titik Lokasi',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasLocation
                    ? Colors.grey.shade100
                    : AppTheme.primary,
                foregroundColor:
                    hasLocation ? AppTheme.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Note Field ────────────────────────────────────────────────────────────
  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _noteCtrl,
        minLines: 3,
        maxLines: 5,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Misalnya: jumlah aktual diambil, kondisi barang, dll.',
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  // ── Bottom Bar (Kirim) ────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_canSubmit && !_sending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      _photo == null && _position == null
                          ? 'Foto & lokasi wajib diisi'
                          : _photo == null
                              ? 'Foto barang wajib diisi'
                              : 'Titik lokasi wajib diisi',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.2),
                      )
                    : const Icon(Icons.send_rounded, size: 17),
                label: Text(
                  _sending ? 'Mengirim ke admin...' : 'Kirim ke Admin',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusApproved,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
