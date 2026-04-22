import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Item Database — 6 kategori × 30 barang IPAL (tanpa harga)
//
// Stok, lokasi, satuan dibuat deterministik dari ID supaya stabil
// (tidak berubah-ubah setiap kali halaman dibuka).
// ─────────────────────────────────────────────────────────────────────────────

class IpalItem {
  final String id;       // contoh: P01, F12, B07
  final String category; // contoh: Pompa IPAL
  final String name;
  final int stock;
  final String unit;
  final String location;

  const IpalItem({
    required this.id,
    required this.category,
    required this.name,
    required this.stock,
    required this.unit,
    required this.location,
  });
}

class IpalCategory {
  final String name;
  final String prefix; // P, F, B, K, R, S
  final IconData icon;
  final Color color;
  final String description;

  const IpalCategory({
    required this.name,
    required this.prefix,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// 6 kategori utama
const List<IpalCategory> kIpalCategories = [
  IpalCategory(
    name: 'Pompa IPAL',
    prefix: 'P',
    icon: Icons.water_drop_rounded,
    color: AppTheme.primary,
    description: 'Pompa, impeller, bearing, motor',
  ),
  IpalCategory(
    name: 'Filter IPAL',
    prefix: 'F',
    icon: Icons.filter_alt_rounded,
    color: Color(0xFF26A69A),
    description: 'Cartridge, membran, media filter',
  ),
  IpalCategory(
    name: 'Blower Aerasi',
    prefix: 'B',
    icon: Icons.air_rounded,
    color: Color(0xFF7B1FA2),
    description: 'Blower, diffuser, selang udara',
  ),
  IpalCategory(
    name: 'Panel Kontrol',
    prefix: 'K',
    icon: Icons.electrical_services_rounded,
    color: Color(0xFFFF7043),
    description: 'MCB, contactor, kabel, PLC',
  ),
  IpalCategory(
    name: 'Rangka IPAL',
    prefix: 'R',
    icon: Icons.construction_rounded,
    color: Color(0xFF8D6E63),
    description: 'Besi, plat, baut, cat',
  ),
  IpalCategory(
    name: 'Pipa dan Saluran',
    prefix: 'S',
    icon: Icons.plumbing_rounded,
    color: Color(0xFF1976D2),
    description: 'Pipa PVC, valve, fitting',
  ),
];

// ─── Data mentah (180 item, tanpa harga) ─────────────────────────────────────
const List<List<String>> _kRawItems = [
  ['P01', 'Pompa IPAL', 'Pompa Submersible 0.5 HP'],
  ['P02', 'Pompa IPAL', 'Pompa Submersible 1 HP'],
  ['P03', 'Pompa IPAL', 'Pompa Submersible 2 HP'],
  ['P04', 'Pompa IPAL', 'Impeller Pompa 4"'],
  ['P05', 'Pompa IPAL', 'Impeller Pompa 6"'],
  ['P06', 'Pompa IPAL', 'Bearing 6204 ZZ'],
  ['P07', 'Pompa IPAL', 'Bearing 6205 ZZ'],
  ['P08', 'Pompa IPAL', 'Bearing 6206 ZZ'],
  ['P09', 'Pompa IPAL', 'Bearing 6208 ZZ'],
  ['P10', 'Pompa IPAL', 'Seal Mekanik 20mm'],
  ['P11', 'Pompa IPAL', 'Seal Mekanik 25mm'],
  ['P12', 'Pompa IPAL', 'Seal Mekanik 32mm'],
  ['P13', 'Pompa IPAL', 'O-Ring Pompa Set'],
  ['P14', 'Pompa IPAL', 'Shaft Pompa 20mm'],
  ['P15', 'Pompa IPAL', 'Shaft Pompa 25mm'],
  ['P16', 'Pompa IPAL', 'Motor Pompa 0.5 HP'],
  ['P17', 'Pompa IPAL', 'Motor Pompa 1 HP'],
  ['P18', 'Pompa IPAL', 'V-Belt A-38'],
  ['P19', 'Pompa IPAL', 'V-Belt A-42'],
  ['P20', 'Pompa IPAL', 'V-Belt A-48'],
  ['P21', 'Pompa IPAL', 'Pulley 3"'],
  ['P22', 'Pompa IPAL', 'Pulley 4"'],
  ['P23', 'Pompa IPAL', 'Kopling Fleksibel'],
  ['P24', 'Pompa IPAL', 'Strainer Saringan Isap'],
  ['P25', 'Pompa IPAL', 'Check Valve 1"'],
  ['P26', 'Pompa IPAL', 'Check Valve 1.5"'],
  ['P27', 'Pompa IPAL', 'Gate Valve 1"'],
  ['P28', 'Pompa IPAL', 'Kabel Power Pompa 5m'],
  ['P29', 'Pompa IPAL', 'Panel Box Pompa IP55'],
  ['P30', 'Pompa IPAL', 'Oli Pelumas Pompa 1L'],
  ['F01', 'Filter IPAL', 'Filter Cartridge 10" 5µm'],
  ['F02', 'Filter IPAL', 'Filter Cartridge 10" 1µm'],
  ['F03', 'Filter IPAL', 'Filter Cartridge 20" 5µm'],
  ['F04', 'Filter IPAL', 'Membran RO 4040'],
  ['F05', 'Filter IPAL', 'Membran UF 4040'],
  ['F06', 'Filter IPAL', 'Membran MF 0.1µm'],
  ['F07', 'Filter IPAL', 'Housing Filter 10"'],
  ['F08', 'Filter IPAL', 'Housing Filter 20"'],
  ['F09', 'Filter IPAL', 'Media Zeolit 25kg'],
  ['F10', 'Filter IPAL', 'Media Pasir Silika 25kg'],
  ['F11', 'Filter IPAL', 'Media Karbon Aktif 25kg'],
  ['F12', 'Filter IPAL', 'Media Antrasit 25kg'],
  ['F13', 'Filter IPAL', 'Media Mangan Zeolit 25kg'],
  ['F14', 'Filter IPAL', 'Resin Kation 25L'],
  ['F15', 'Filter IPAL', 'Resin Anion 25L'],
  ['F16', 'Filter IPAL', 'Bak Filter FRP 10"'],
  ['F17', 'Filter IPAL', 'Bak Filter FRP 12"'],
  ['F18', 'Filter IPAL', 'Lateral Underdrain'],
  ['F19', 'Filter IPAL', 'O-Ring Housing Filter'],
  ['F20', 'Filter IPAL', 'Kunci Spanner Filter'],
  ['F21', 'Filter IPAL', 'Pressure Gauge 0-6 Bar'],
  ['F22', 'Filter IPAL', 'Flow Meter 1/2"'],
  ['F23', 'Filter IPAL', 'Backwash Valve 1"'],
  ['F24', 'Filter IPAL', 'Multiport Valve 1.5"'],
  ['F25', 'Filter IPAL', 'Pre-Filter Sedimen 50µm'],
  ['F26', 'Filter IPAL', 'Post Filter CTO'],
  ['F27', 'Filter IPAL', 'UV Sterilizer 6W'],
  ['F28', 'Filter IPAL', 'UV Sterilizer 11W'],
  ['F29', 'Filter IPAL', 'Dosing Pump 12V'],
  ['F30', 'Filter IPAL', 'Kaporit Tablet 1kg'],
  ['B01', 'Blower Aerasi', 'Blower Roots 1/2 HP'],
  ['B02', 'Blower Aerasi', 'Blower Roots 1 HP'],
  ['B03', 'Blower Aerasi', 'Blower Roots 2 HP'],
  ['B04', 'Blower Aerasi', 'Blower Vortex 250W'],
  ['B05', 'Blower Aerasi', 'Blower Vortex 550W'],
  ['B06', 'Blower Aerasi', 'Diffuser Gelembung Halus 9"'],
  ['B07', 'Blower Aerasi', 'Diffuser Gelembung Halus 12"'],
  ['B08', 'Blower Aerasi', 'Diffuser Gelembung Kasar'],
  ['B09', 'Blower Aerasi', 'Air Stone Silinder'],
  ['B10', 'Blower Aerasi', 'Selang Udara 6mm (per meter)'],
  ['B11', 'Blower Aerasi', 'Selang Udara 8mm (per meter)'],
  ['B12', 'Blower Aerasi', 'Manifold Udara 1/2"'],
  ['B13', 'Blower Aerasi', 'Manifold Udara 1"'],
  ['B14', 'Blower Aerasi', 'Solenoid Valve Udara 1/2"'],
  ['B15', 'Blower Aerasi', 'Check Valve Udara 1/2"'],
  ['B16', 'Blower Aerasi', 'Ball Valve PVC 1/2"'],
  ['B17', 'Blower Aerasi', 'Pressure Switch Blower'],
  ['B18', 'Blower Aerasi', 'Filter Udara Blower'],
  ['B19', 'Blower Aerasi', 'Timing Control Blower'],
  ['B20', 'Blower Aerasi', 'Bearing Blower 6204'],
  ['B21', 'Blower Aerasi', 'Bearing Blower 6206'],
  ['B22', 'Blower Aerasi', 'Impeller Blower'],
  ['B23', 'Blower Aerasi', 'Gasket Blower Set'],
  ['B24', 'Blower Aerasi', 'Kapasitor Blower 16µF'],
  ['B25', 'Blower Aerasi', 'Kapasitor Blower 20µF'],
  ['B26', 'Blower Aerasi', 'Motor Blower 1/4 HP'],
  ['B27', 'Blower Aerasi', 'Motor Blower 1/2 HP'],
  ['B28', 'Blower Aerasi', 'Inlet Filter Blower'],
  ['B29', 'Blower Aerasi', 'Silencer Blower'],
  ['B30', 'Blower Aerasi', 'Klem Selang 6mm (5pcs)'],
  ['K01', 'Panel Kontrol', 'MCB 1 Phase 6A'],
  ['K02', 'Panel Kontrol', 'MCB 1 Phase 10A'],
  ['K03', 'Panel Kontrol', 'MCB 1 Phase 16A'],
  ['K04', 'Panel Kontrol', 'MCB 3 Phase 10A'],
  ['K05', 'Panel Kontrol', 'MCB 3 Phase 16A'],
  ['K06', 'Panel Kontrol', 'Contactor 9A'],
  ['K07', 'Panel Kontrol', 'Contactor 12A'],
  ['K08', 'Panel Kontrol', 'Contactor 18A'],
  ['K09', 'Panel Kontrol', 'Overload Relay 4-6A'],
  ['K10', 'Panel Kontrol', 'Overload Relay 6-10A'],
  ['K11', 'Panel Kontrol', 'Timer Relay On-Delay'],
  ['K12', 'Panel Kontrol', 'Timer Relay Cyclic'],
  ['K13', 'Panel Kontrol', 'Tombol Start (NO)'],
  ['K14', 'Panel Kontrol', 'Tombol Stop (NC)'],
  ['K15', 'Panel Kontrol', 'Selector Switch 3 Posisi'],
  ['K16', 'Panel Kontrol', 'Pilot Lamp LED Merah'],
  ['K17', 'Panel Kontrol', 'Pilot Lamp LED Hijau'],
  ['K18', 'Panel Kontrol', 'Terminal Block 6mm²'],
  ['K19', 'Panel Kontrol', 'DIN Rail 35mm / 1m'],
  ['K20', 'Panel Kontrol', 'Box Panel IP54 400x300'],
  ['K21', 'Panel Kontrol', 'Box Panel IP54 600x400'],
  ['K22', 'Panel Kontrol', 'Cable Duct 40x40mm / 1m'],
  ['K23', 'Panel Kontrol', 'Kabel NYY 3x2.5mm / 1m'],
  ['K24', 'Panel Kontrol', 'Kabel NYY 4x4mm / 1m'],
  ['K25', 'Panel Kontrol', 'Gland Kabel M20'],
  ['K26', 'Panel Kontrol', 'Ampere Meter Analog'],
  ['K27', 'Panel Kontrol', 'Volt Meter Analog'],
  ['K28', 'Panel Kontrol', 'Float Switch Level'],
  ['K29', 'Panel Kontrol', 'PLC Mikro 8 I/O'],
  ['K30', 'Panel Kontrol', 'HMI Display 4.3"'],
  ['R01', 'Rangka IPAL', 'Besi Siku 40x40x4mm / 6m'],
  ['R02', 'Rangka IPAL', 'Besi Siku 50x50x5mm / 6m'],
  ['R03', 'Rangka IPAL', 'Besi Hollow 40x40mm / 6m'],
  ['R04', 'Rangka IPAL', 'Besi Hollow 50x50mm / 6m'],
  ['R05', 'Rangka IPAL', 'Besi UNP 80 / 6m'],
  ['R06', 'Rangka IPAL', 'Plat Besi 3mm / lembar'],
  ['R07', 'Rangka IPAL', 'Plat Besi 5mm / lembar'],
  ['R08', 'Rangka IPAL', 'Plat Besi 8mm / lembar'],
  ['R09', 'Rangka IPAL', 'Baut M10x30 (10pcs)'],
  ['R10', 'Rangka IPAL', 'Baut M12x40 (10pcs)'],
  ['R11', 'Rangka IPAL', 'Mur & Baut M10 Set'],
  ['R12', 'Rangka IPAL', 'Mur & Baut M12 Set'],
  ['R13', 'Rangka IPAL', 'Cat Anti Karat 1kg'],
  ['R14', 'Rangka IPAL', 'Cat Anti Karat 5kg'],
  ['R15', 'Rangka IPAL', 'Thinner 1L'],
  ['R16', 'Rangka IPAL', 'Elektroda Las E6013 2.6mm / kg'],
  ['R17', 'Rangka IPAL', 'Elektroda Las E6013 3.2mm / kg'],
  ['R18', 'Rangka IPAL', 'Amplas Roll 80 Grit / m'],
  ['R19', 'Rangka IPAL', 'Dempul Besi 1kg'],
  ['R20', 'Rangka IPAL', 'Kaki Mesin Rubber Feet'],
  ['R21', 'Rangka IPAL', 'Angkur Fisher M10 (10pcs)'],
  ['R22', 'Rangka IPAL', 'Pipa GIP 1.5" / 6m'],
  ['R23', 'Rangka IPAL', 'Engsel Pintu Stainless'],
  ['R24', 'Rangka IPAL', 'Kunci Gembok Panel'],
  ['R25', 'Rangka IPAL', 'Plat Stainless 1.5mm'],
  ['R26', 'Rangka IPAL', 'Besi Round Bar 16mm / 6m'],
  ['R27', 'Rangka IPAL', 'Besi Round Bar 20mm / 6m'],
  ['R28', 'Rangka IPAL', 'Bracket Dinding L-50'],
  ['R29', 'Rangka IPAL', 'Grip Karet Anti Getar'],
  ['R30', 'Rangka IPAL', 'Zinc Chromate Primer 1kg'],
  ['S01', 'Pipa dan Saluran', 'Pipa PVC AW 1/2" / 6m'],
  ['S02', 'Pipa dan Saluran', 'Pipa PVC AW 3/4" / 6m'],
  ['S03', 'Pipa dan Saluran', 'Pipa PVC AW 1" / 6m'],
  ['S04', 'Pipa dan Saluran', 'Pipa PVC AW 1.5" / 6m'],
  ['S05', 'Pipa dan Saluran', 'Pipa PVC AW 2" / 6m'],
  ['S06', 'Pipa dan Saluran', 'Pipa PVC AW 3" / 6m'],
  ['S07', 'Pipa dan Saluran', 'Pipa PVC AW 4" / 6m'],
  ['S08', 'Pipa dan Saluran', 'Elbow 90° PVC 1"'],
  ['S09', 'Pipa dan Saluran', 'Elbow 90° PVC 2"'],
  ['S10', 'Pipa dan Saluran', 'Elbow 45° PVC 2"'],
  ['S11', 'Pipa dan Saluran', 'Tee PVC 1"'],
  ['S12', 'Pipa dan Saluran', 'Tee PVC 2"'],
  ['S13', 'Pipa dan Saluran', 'Reducer PVC 2" x 1"'],
  ['S14', 'Pipa dan Saluran', 'Sambungan Drat Luar 1"'],
  ['S15', 'Pipa dan Saluran', 'Sambungan Drat Dalam 1"'],
  ['S16', 'Pipa dan Saluran', 'Ball Valve PVC 1"'],
  ['S17', 'Pipa dan Saluran', 'Ball Valve PVC 1.5"'],
  ['S18', 'Pipa dan Saluran', 'Ball Valve PVC 2"'],
  ['S19', 'Pipa dan Saluran', 'Gate Valve PVC 2"'],
  ['S20', 'Pipa dan Saluran', 'Gate Valve PVC 3"'],
  ['S21', 'Pipa dan Saluran', 'Check Valve PVC 1"'],
  ['S22', 'Pipa dan Saluran', 'Check Valve PVC 2"'],
  ['S23', 'Pipa dan Saluran', 'Lem PVC Wavin 250cc'],
  ['S24', 'Pipa dan Saluran', 'Seal Tape PTFE 12mm'],
  ['S25', 'Pipa dan Saluran', 'Klem Pipa 1" (10pcs)'],
  ['S26', 'Pipa dan Saluran', 'Klem Pipa 2" (10pcs)'],
  ['S27', 'Pipa dan Saluran', 'Saringan Y-Type 1"'],
  ['S28', 'Pipa dan Saluran', 'Saringan Y-Type 2"'],
  ['S29', 'Pipa dan Saluran', 'Flexible Hose 1" / 30cm'],
  ['S30', 'Pipa dan Saluran', 'Union PVC 1.5"'],
];

// ─── Helper deterministik untuk stok / satuan / lokasi ───────────────────────
int _hash(String s) {
  var h = 0;
  for (var i = 0; i < s.length; i++) {
    h = (h * 31 + s.codeUnitAt(i)) & 0x7fffffff;
  }
  return h;
}

String _pickUnit(String name) {
  final n = name.toLowerCase();
  if (n.contains('/ kg') || n.contains(' kg')) return 'kg';
  if (n.contains('/ 1m') || n.contains('/ 6m') || n.contains('per meter') ||
      n.contains('/ m') || n.contains('/30cm')) return 'meter';
  if (n.contains('/ lembar')) return 'lembar';
  if (n.contains(' l') && (n.contains('1l') || n.contains('25l'))) return 'liter';
  if (n.contains('(10pcs)') || n.contains('(5pcs)')) return 'set';
  if (n.contains('250cc')) return 'botol';
  return 'unit';
}

String _pickLocation(String id) {
  final racks = ['A', 'B', 'C', 'D', 'E'];
  final h = _hash(id);
  final rack = racks[h % racks.length];
  final shelf = (h ~/ 5) % 20 + 1;
  return 'Gudang IPAL · Rak $rack-${shelf.toString().padLeft(2, '0')}';
}

int _pickStock(String id) {
  final h = _hash(id);
  // ~10% kosong, ~25% hampir habis, sisanya tersedia
  final mod = h % 100;
  if (mod < 10) return 0;
  if (mod < 35) return (h % 5) + 1;        // 1–5
  return (h % 95) + 6;                      // 6–100
}

// ─── Build full list ─────────────────────────────────────────────────────────
List<IpalItem> _allItemsCache = const [];

List<IpalItem> getAllItems() {
  if (_allItemsCache.isNotEmpty) return _allItemsCache;
  _allItemsCache = _kRawItems.map((row) {
    final id = row[0];
    final cat = row[1];
    final name = row[2];
    return IpalItem(
      id: id,
      category: cat,
      name: name,
      stock: _pickStock(id),
      unit: _pickUnit(name),
      location: _pickLocation(id),
    );
  }).toList();
  return _allItemsCache;
}

List<IpalItem> getItemsByCategory(String category) =>
    getAllItems().where((e) => e.category == category).toList();

IpalCategory categoryByName(String name) =>
    kIpalCategories.firstWhere((c) => c.name == name,
        orElse: () => kIpalCategories.first);

// ─── Status stok helper ──────────────────────────────────────────────────────
enum StockStatus { available, low, empty }

StockStatus stockStatusOf(int stock) {
  if (stock <= 0) return StockStatus.empty;
  if (stock <= 5) return StockStatus.low;
  return StockStatus.available;
}

Color stockStatusColor(StockStatus s) {
  switch (s) {
    case StockStatus.available:
      return AppTheme.statusApproved;
    case StockStatus.low:
      return AppTheme.statusPending;
    case StockStatus.empty:
      return AppTheme.statusRejected;
  }
}

String stockStatusLabel(StockStatus s) {
  switch (s) {
    case StockStatus.available:
      return 'Tersedia';
    case StockStatus.low:
      return 'Hampir Habis';
    case StockStatus.empty:
      return 'Stok Habis';
  }
}

// ─── Dummy riwayat request per item (deterministik) ──────────────────────────
List<Map<String, String>> historyForItem(String id) {
  final h = _hash(id);
  final count = (h % 4) + 2; // 2–5 entri
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final approvers = ['Ahmad Fauzi', 'Siti Rahayu', 'Rudi Hermawan', '-'];
  final statuses = ['completed', 'completed', 'approved', 'pending', 'rejected'];

  return List.generate(count, (i) {
    final seed = h + i * 17;
    final day = (seed % 27) + 1;
    final month = (seed ~/ 7) % 12;
    final year = 2026 - ((seed ~/ 91) % 2);
    final qty = ((seed ~/ 3) % 5) + 1;
    final status = statuses[seed % statuses.length];
    final approver = status == 'pending'
        ? '-'
        : approvers[seed % (approvers.length - 1)];
    return {
      'code':
          'REQ-$year${(month + 1).toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}-${(seed % 999).toString().padLeft(3, '0')}',
      'date': '${day.toString().padLeft(2, '0')} ${months[month]} $year',
      'qty': '$qty',
      'status': status,
      'approver': approver,
    };
  });
}
