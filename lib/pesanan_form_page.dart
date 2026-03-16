import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'menu_model.dart';
import 'pesanan_model.dart';
import 'supabase_service.dart';

class _ItemPesan {
  MenuModel menu;
  int jumlah;
  _ItemPesan({required this.menu, this.jumlah = 1});
}

class PesananFormPage extends StatefulWidget {
  final PesananModel? pesanan;
  const PesananFormPage({super.key, this.pesanan});

  @override
  State<PesananFormPage> createState() => _PesananFormPageState();
}

class _PesananFormPageState extends State<PesananFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _mejaCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  bool _loading = false;
  bool _loadingMenu = true;

  List<MenuModel> _menuList = [];
  final List<_ItemPesan> _selectedItems = [];

  bool get isEdit => widget.pesanan != null;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int get _totalHarga => _selectedItems.fold(
    0,
    (sum, item) => sum + (item.menu.harga * item.jumlah),
  );

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaCtrl.text = widget.pesanan!.namaPelanggan;
      _mejaCtrl.text = widget.pesanan!.nomorMeja.toString();
      _catatanCtrl.text = widget.pesanan!.catatan ?? '';
    }
    _loadMenu();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _mejaCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    try {
      final menus = await SupabaseService.getMenu();
      setState(() {
        _menuList = menus.where((m) => m.tersedia).toList();
        _loadingMenu = false;
      });
    } catch (e) {
      setState(() => _loadingMenu = false);
    }
  }

  void _tambahItem(MenuModel menu) {
    final existing = _selectedItems.indexWhere((i) => i.menu.id == menu.id);
    if (existing >= 0) {
      setState(() => _selectedItems[existing].jumlah++);
    } else {
      setState(() => _selectedItems.add(_ItemPesan(menu: menu)));
    }
  }

  void _kurangItem(MenuModel menu) {
    final existing = _selectedItems.indexWhere((i) => i.menu.id == menu.id);
    if (existing >= 0) {
      if (_selectedItems[existing].jumlah <= 1) {
        setState(() => _selectedItems.removeAt(existing));
      } else {
        setState(() => _selectedItems[existing].jumlah--);
      }
    }
  }

  int _getJumlah(MenuModel menu) {
    final existing = _selectedItems.indexWhere((i) => i.menu.id == menu.id);
    return existing >= 0 ? _selectedItems[existing].jumlah : 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty && !isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 menu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final pesanan = PesananModel(
        id: widget.pesanan?.id ?? '',
        namaPelanggan: _namaCtrl.text.trim(),
        nomorMeja: int.parse(_mejaCtrl.text),
        catatan: _catatanCtrl.text.trim().isEmpty
            ? null
            : _catatanCtrl.text.trim(),
        status: widget.pesanan?.status ?? 'Menunggu',
        totalHarga: _totalHarga,
      );

      if (isEdit) {
        await SupabaseService.updatePesanan(widget.pesanan!.id, pesanan);
      } else {
        final pesananId = await SupabaseService.tambahPesanan(pesanan);
        for (final item in _selectedItems) {
          await SupabaseService.tambahDetailPesanan(
            pesananId,
            item.menu.id,
            item.menu.namaMenu,
            item.menu.harga,
            item.jumlah,
          );
        }
        await SupabaseService.updateTotalHarga(pesananId, _totalHarga);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? '✅ Pesanan berhasil diperbarui'
                  : '✅ Pesanan berhasil dibuat',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pesanan' : 'Buat Pesanan Baru'),
      ),
      body: _loadingMenu
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- INFO PELANGGAN ----
                    Text(
                      'Informasi Pelanggan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama pelanggan wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mejaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nomor Meja *',
                        prefixIcon: Icon(Icons.table_restaurant_outlined),
                        hintText: 'e.g. 5',
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nomor meja wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        prefixIcon: Icon(Icons.note_outlined),
                        hintText: 'e.g. Tidak pakai cabai, alergi seafood...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (!isEdit) ...[
                      // ---- PILIH MENU ----
                      Text(
                        'Pilih Menu',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_menuList.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '⚠️ Belum ada menu tersedia. Tambahkan menu dulu!',
                            ),
                          ),
                        )
                      else
                        ..._menuList.map((menu) {
                          final jumlah = _getJumlah(menu);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                menu.namaMenu,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                currencyFormat.format(menu.harga),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: jumlah > 0
                                        ? () => _kurangItem(menu)
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Center(
                                      child: Text(
                                        '$jumlah',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: jumlah > 0
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _tambahItem(menu),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      if (_selectedItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.08),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan Pesanan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Divider(),
                                ..._selectedItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.menu.namaMenu} x${item.jumlah}',
                                        ),
                                        Text(
                                          currencyFormat.format(
                                            item.menu.harga * item.jumlah,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(_totalHarga),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(isEdit ? Icons.save : Icons.receipt_long),
                        label: Text(
                          isEdit ? 'Simpan Perubahan' : 'Konfirmasi Pesanan',
                        ),
                        onPressed: _loading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
