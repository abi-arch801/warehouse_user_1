import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Scan Barcode Page — buka kamera untuk scan kode barang
//
// Pakai package: image_picker (tambahkan di pubspec.yaml)
//   image_picker: ^1.1.2
//
// Untuk scan barcode asli (decode QR/barcode dari kamera), bisa
// upgrade nanti ke `mobile_scanner`. Saat ini halaman ini:
//   1) Tampilkan UI viewfinder.
//   2) Tombol bawah → buka kamera HP via image_picker.
//   3) Tombol ke-2 → ambil dari galeri.
//   4) Setelah foto diambil, tampilkan preview & tombol "Gunakan".
// ─────────────────────────────────────────────────────────────────────────────

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _busy = false;

  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final img = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (img != null) setState(() => _capturedImage = img);
    } catch (e) {
      _showError('Tidak bisa membuka kamera: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (img != null) setState(() => _capturedImage = img);
    } catch (e) {
      _showError('Tidak bisa membuka galeri: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.statusRejected,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _useScan() {
    HapticFeedback.mediumImpact();
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
            const Text('Sedang Dikembangkan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Fitur deteksi kode dari hasil scan masih dalam tahap pengembangan. '
          'Untuk sementara silakan ketik kode barang manual di halaman list barang.',
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Scan Barcode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            _capturedImage != null ? _buildPreview() : _buildViewfinder(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Viewfinder ────────────────────────────────────────────────────────────
  Widget _buildViewfinder() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Stack(
                children: [
                  // 4 sudut
                  ..._corners(),
                  // Garis scan
                  AnimatedBuilder(
                    animation: _scanCtrl,
                    builder: (_, __) => Positioned(
                      left: 12,
                      right: 12,
                      top: 12 + (_scanCtrl.value * 226),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0),
                              AppTheme.primary,
                              AppTheme.primary.withOpacity(0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 200,
            child: Column(
              children: [
                const Text(
                  'Arahkan kamera ke barcode barang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pastikan barcode berada di dalam kotak',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const c = AppTheme.primary;
    Widget corner({double? top, double? bottom, double? left, double? right}) {
      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border(
              top: top != null ? const BorderSide(color: c, width: 3) : BorderSide.none,
              bottom: bottom != null ? const BorderSide(color: c, width: 3) : BorderSide.none,
              left: left != null ? const BorderSide(color: c, width: 3) : BorderSide.none,
              right: right != null ? const BorderSide(color: c, width: 3) : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(top: 0, left: 0),
      corner(top: 0, right: 0),
      corner(bottom: 0, left: 0),
      corner(bottom: 0, right: 0),
    ];
  }

  // ── Preview hasil capture ─────────────────────────────────────────────────
  Widget _buildPreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_capturedImage!.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: _capturedImage == null
              ? _buildScanActions()
              : _buildPreviewActions(),
        ),
      ),
    );
  }

  Widget _buildScanActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleAction(
          icon: Icons.photo_library_rounded,
          label: 'Galeri',
          onTap: _pickFromGallery,
        ),
        GestureDetector(
          onTap: _openCamera,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _busy
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 32),
          ),
        ),
        _circleAction(
          icon: Icons.keyboard_rounded,
          label: 'Manual',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPreviewActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _capturedImage = null),
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 18),
            label: const Text('Ulangi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                )),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.white54, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _useScan,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Gunakan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
