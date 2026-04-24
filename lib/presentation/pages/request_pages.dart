import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Request Page — Form Buat Request Barang
//
// Bisa dipanggil dengan dua cara:
//  1. Tanpa argumen  -> form kosong (dari tombol "Buat Request Barang")
//  2. Dengan prefillItem -> field item pertama otomatis terisi
//     (dari kartu "Barang Sering Diminta" / Detail Request Page)
//
// REVISI:
// - Selector "Sumber Barang" di paling atas:
//     • Dari Gudang  -> form sederhana + upload foto contoh
//     • Dari Luar    -> form berbeda (nama, spesifikasi, foto, link, harga)
// - User bisa request hingga 5 jenis barang sekaligus dalam 1 request,
//   berlaku untuk kedua sumber. Tombol "Tambah Barang" muncul di bawah
//   daftar barang dan dinonaktifkan saat sudah mencapai 5.
// - Daftar barang "Dari Gudang" dan "Dari Luar" disimpan TERPISAH:
//   menambah barang di salah satu mode tidak mempengaruhi mode lain.
//   Saat user pindah sumber, daftar masing-masing tetap utuh.
// ─────────────────────────────────────────────────────────────────────────────

const int _kMaxItems = 5;

class _ItemEntry {
  // ── Field umum (Dari Gudang)
  final TextEditingController itemCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();

  // ── Field umum kedua mode
  final TextEditingController qtyCtrl = TextEditingController();
  String unit = 'unit';
  String? photoLabel;

  // ── Field tambahan (Dari Luar)
  final TextEditingController extNameCtrl = TextEditingController();
  final TextEditingController extSpecCtrl = TextEditingController();
  final TextEditingController extLinkCtrl = TextEditingController();
  final TextEditingController extPriceCtrl = TextEditingController();

  void dispose() {
    itemCtrl.dispose();
    codeCtrl.dispose();
    qtyCtrl.dispose();
    extNameCtrl.dispose();
    extSpecCtrl.dispose();
    extLinkCtrl.dispose();
    extPriceCtrl.dispose();
  }
}

class RequestPage extends StatefulWidget {
  final Map<String, dynamic>? prefillItem;

  const RequestPage({super.key, this.prefillItem});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Sumber barang ───────────────────────────────────────────────────────
  // 'gudang' = ambil dari stok gudang
  // 'luar'   = beli dari luar
  String _source = 'gudang';

  // ── Daftar barang TERPISAH per sumber (masing-masing 1–5) ───────────────
  // Menambah / menghapus di salah satu list TIDAK mempengaruhi list lainnya.
  final List<_ItemEntry> _warehouseItems = [];
  final List<_ItemEntry> _externalItems = [];

  // List aktif sesuai sumber yang sedang dipilih.
  List<_ItemEntry> get _items =>
      _source == 'gudang' ? _warehouseItems : _externalItems;

  // ── Field di tingkat request (shared semua barang) ──────────────────────
  final _notesCtrl = TextEditingController();
  String _urgency = 'normal';
  DateTime _neededDate = DateTime.now().add(const Duration(days: 3));

  static const _units = [
    'unit',
    'pcs',
    'kg',
    'liter',
    'modul',
    'batang',
    'roll'
  ];

  @override
  void initState() {
    super.initState();
    // Setiap mode dimulai dengan 1 entry kosong agar list-nya tidak pernah 0.
    final warehouseFirst = _ItemEntry();
    final externalFirst = _ItemEntry();

    // Prefill (jika ada) hanya mengisi item pertama mode "Dari Gudang",
    // karena prefillItem berasal dari katalog stok gudang.
    final p = widget.prefillItem;
    if (p != null) {
      warehouseFirst.itemCtrl.text = (p['name'] ?? '') as String;
      warehouseFirst.codeCtrl.text = (p['code'] ?? '') as String;
      if (p['unit'] != null && _units.contains(p['unit'])) {
        warehouseFirst.unit = p['unit'] as String;
      }
    }

    _warehouseItems.add(warehouseFirst);
    _externalItems.add(externalFirst);
  }

  @override
  void dispose() {
    for (final it in _warehouseItems) {
      it.dispose();
    }
    for (final it in _externalItems) {
      it.dispose();
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Manipulasi list barang ──────────────────────────────────────────────
  void _addItem() {
    if (_items.length >= _kMaxItems) return;
    HapticFeedback.selectionClick();
    setState(() => _items.add(_ItemEntry()));
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    HapticFeedback.lightImpact();
    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _neededDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _neededDate = picked);
  }

  // Bottom-sheet pemilihan sumber foto. Tidak benar-benar mengambil foto
  // (placeholder), cukup menandai bahwa foto sudah dipilih.
  Future<void> _pickPhoto(_ItemEntry entry) async {
    HapticFeedback.selectionClick();
    final hasPhoto = entry.photoLabel != null;
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
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
                'Unggah Foto Contoh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _photoSourceTile(
              icon: Icons.photo_camera_rounded,
              title: 'Ambil dari Kamera',
              subtitle: 'Foto langsung dari kamera perangkat',
              onTap: () => Navigator.pop(ctx, 'Foto Kamera'),
            ),
            const SizedBox(height: 10),
            _photoSourceTile(
              icon: Icons.photo_library_rounded,
              title: 'Pilih dari Galeri',
              subtitle: 'Pilih foto yang sudah ada di galeri',
              onTap: () => Navigator.pop(ctx, 'Foto Galeri'),
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 10),
              _photoSourceTile(
                icon: Icons.delete_outline_rounded,
                title: 'Hapus Foto',
                subtitle: 'Batalkan unggahan foto contoh',
                color: AppTheme.statusRejected,
                onTap: () => Navigator.pop(ctx, '__remove__'),
              ),
            ],
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      entry.photoLabel = result == '__remove__' ? null : result;
    });
  }

  Widget _photoSourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppTheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: c, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: color ?? AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final isExternal = _source == 'luar';
    final count = _items.length;

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
                'Request Berhasil Dikirim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isExternal
                    ? '$count jenis barang dari luar dikirim untuk persetujuan approver.'
                    : '$count jenis barang dari gudang dikirim untuk persetujuan approver.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
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

  @override
  Widget build(BuildContext context) {
    final canAddMore = _items.length < _kMaxItems;
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Selector sumber barang
                      _sectionLabel('Sumber Barang'),
                      const SizedBox(height: 10),
                      _buildSourceSelector(),
                      const SizedBox(height: 22),

                      // ── Header daftar barang + counter
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _sectionLabel(_source == 'gudang'
                                ? 'Daftar Barang dari Gudang'
                                : 'Daftar Barang dari Luar'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_items.length}/$_kMaxItems jenis',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── List item cards
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: Column(
                          children: List.generate(_items.length, (i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      i == _items.length - 1 ? 0 : 12),
                              child: _buildItemCard(i),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // ── Tombol tambah barang
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: canAddMore ? _addItem : null,
                          icon: Icon(
                            canAddMore
                                ? Icons.add_rounded
                                : Icons.block_rounded,
                            size: 18,
                          ),
                          label: Text(
                            canAddMore
                                ? 'Tambah Barang (${_items.length}/$_kMaxItems)'
                                : 'Maksimal $_kMaxItems jenis barang',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: canAddMore
                                ? AppTheme.primary
                                : Colors.grey.shade500,
                            side: BorderSide(
                              color: canAddMore
                                  ? AppTheme.primary.withOpacity(0.5)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                      _sectionLabel('Detail Permintaan'),
                      const SizedBox(height: 10),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildUrgencySelector(),
                            const SizedBox(height: 14),
                            _buildDateField(),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller: _notesCtrl,
                              label: 'Catatan / Keperluan',
                              hint:
                                  'Tuliskan tujuan penggunaan barang...',
                              icon: Icons.notes_rounded,
                              maxLines: 4,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Tolong jelaskan keperluannya'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildInfoBanner(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            shadowColor: AppTheme.primary.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Kirim Request (${_items.length} jenis)',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Batal',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Source selector ─────────────────────────────────────────────────────
  Widget _buildSourceSelector() {
    final options = const [
      {
        'value': 'gudang',
        'title': 'Dari Gudang',
        'subtitle': 'Ambil dari stok yang tersedia',
        'icon': Icons.warehouse_rounded,
      },
      {
        'value': 'luar',
        'title': 'Dari Luar',
        'subtitle': 'Beli dari supplier / toko luar',
        'icon': Icons.storefront_rounded,
      },
    ];
    return Row(
      children: options.map((opt) {
        final selected = _source == opt['value'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: opt['value'] == 'gudang' ? 6 : 0,
              left: opt['value'] == 'luar' ? 6 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                if (selected) return;
                HapticFeedback.selectionClick();
                setState(() => _source = opt['value'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primary
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withOpacity(0.22)
                            : AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        opt['icon'] as IconData,
                        size: 20,
                        color: selected ? Colors.white : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt['subtitle'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Card per item (header + body sesuai sumber) ─────────────────────────
  Widget _buildItemCard(int index) {
    final entry = _items[index];
    final canRemove = _items.length > 1;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header item
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Barang ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: 'Hapus barang',
                    onPressed: () => _removeItem(index),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppTheme.statusRejected,
                    ),
                  )
                else
                  const SizedBox(width: 4),
              ],
            ),
          ),
          // Body item
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              child: _source == 'gudang'
                  ? _buildWarehouseFields(entry)
                  : _buildExternalFields(entry),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Mode "Dari Gudang" untuk satu entry ───────────────────────────
  Widget _buildWarehouseFields(_ItemEntry e) {
    return Column(
      key: ValueKey('gudang-${e.hashCode}'),
      children: [
        _buildTextField(
          controller: e.itemCtrl,
          label: 'Nama Barang',
          hint: 'Contoh: Pompa Submersible 7.5 kW',
          icon: Icons.inventory_2_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: e.codeCtrl,
          label: 'Kode Barang (opsional)',
          hint: 'Contoh: PUMP-001',
          icon: Icons.qr_code_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: e.qtyCtrl,
                label: 'Jumlah',
                hint: '0',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildDropdown(
                label: 'Satuan',
                icon: Icons.straighten_rounded,
                value: e.unit,
                items: _units,
                onChanged: (v) => setState(() => e.unit = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildPhotoUploader(
          entry: e,
          label: 'Foto Contoh Barang (opsional)',
          helper:
              'Lampirkan foto agar petugas gudang lebih mudah mengenali barang.',
        ),
      ],
    );
  }

  // ── Field Mode "Dari Luar" untuk satu entry ─────────────────────────────
  Widget _buildExternalFields(_ItemEntry e) {
    return Column(
      key: ValueKey('luar-${e.hashCode}'),
      children: [
        _buildTextField(
          controller: e.extNameCtrl,
          label: 'Nama Barang',
          hint: 'Contoh: Pompa Dosing Kimia 12 L/h',
          icon: Icons.inventory_2_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: e.extSpecCtrl,
          label: 'Spesifikasi Barang',
          hint: 'Tulis spesifikasi: kapasitas, daya, material, merk, dll.',
          icon: Icons.list_alt_rounded,
          maxLines: 4,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Spesifikasi wajib diisi'
              : null,
        ),
        const SizedBox(height: 14),
        _buildPhotoUploader(
          entry: e,
          label: 'Foto Contoh Barang',
          helper:
              'Wajib lampirkan foto agar approver bisa memverifikasi barang.',
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: e.extLinkCtrl,
          label: 'Link Pembelian',
          hint: 'https://contoh-toko.com/produk/...',
          icon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Tolong masukkan link pembelian';
            }
            final url = v.trim();
            final ok = url.startsWith('http://') ||
                url.startsWith('https://') ||
                url.contains('.');
            if (!ok) return 'Link tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: e.extPriceCtrl,
          label: 'Estimasi Harga (Rp)',
          hint: 'Contoh: 1.250.000',
          icon: Icons.payments_rounded,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Estimasi harga wajib diisi';
            }
            final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
            final n = int.tryParse(cleaned);
            if (n == null || n <= 0) return 'Harga tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: e.qtyCtrl,
                label: 'Jumlah',
                hint: '0',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildDropdown(
                label: 'Satuan',
                icon: Icons.straighten_rounded,
                value: e.unit,
                items: _units,
                onChanged: (v) => setState(() => e.unit = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Photo uploader (placeholder, siap di-wire ke image_picker) ──────────
  Widget _buildPhotoUploader({
    required _ItemEntry entry,
    required String label,
    required String helper,
  }) {
    final hasPhoto = entry.photoLabel != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickPhoto(entry),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: hasPhoto
                  ? AppTheme.primary.withOpacity(0.06)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto
                    ? AppTheme.primary.withOpacity(0.4)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: hasPhoto
                        ? AppTheme.primary
                        : AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasPhoto
                        ? Icons.image_rounded
                        : Icons.add_a_photo_rounded,
                    color: hasPhoto ? Colors.white : AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasPhoto
                            ? 'Foto terlampir · ${entry.photoLabel!}'
                            : 'Unggah Foto Contoh',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasPhoto
                            ? 'Ketuk untuk mengganti / menghapus foto.'
                            : helper,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  hasPhoto
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: hasPhoto
                      ? AppTheme.statusApproved
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
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
          decoration:
              const BoxDecoration(gradient: AppTheme.primaryGradient),
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
                        'Buat Request Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bisa request hingga $_kMaxItems jenis barang sekaligus',
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

  // ── Helpers ───────────────────────────────────────────────────────────────
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

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, size: 18, color: AppTheme.primary),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 36),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppTheme.statusRejected, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade500),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                    items: items
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    final options = [
      {'value': 'low', 'label': 'Rendah', 'color': AppTheme.statusCompleted},
      {'value': 'normal', 'label': 'Normal', 'color': AppTheme.primary},
      {'value': 'high', 'label': 'Tinggi', 'color': AppTheme.statusPending},
      {'value': 'urgent', 'label': 'Urgent', 'color': AppTheme.statusRejected},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tingkat Urgensi',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final selected = _urgency == opt['value'];
            final c = opt['color'] as Color;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _urgency = opt['value'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? c : c.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? c : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        opt['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : c,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final formatted =
        '${_neededDate.day.toString().padLeft(2, '0')} ${months[_neededDate.month - 1]} ${_neededDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal Dibutuhkan',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    final isExternal = _source == 'luar';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isExternal
                  ? 'Request pembelian dari luar membutuhkan persetujuan tambahan dari approver Divisi IPAL & Bagian Pengadaan. Pastikan link & estimasi harga setiap barang sudah benar.'
                  : 'Request akan diproses oleh approver Divisi IPAL. Pastikan data setiap barang sudah benar sebelum dikirim.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
