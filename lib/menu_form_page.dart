import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_model.dart';
import 'supabase_service.dart';

class MenuFormPage extends StatefulWidget {
  final MenuModel? menu;
  const MenuFormPage({super.key, this.menu});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  String _kategori = 'Udang';
  bool _tersedia = true;
  bool _loading = false;

  bool get isEdit => widget.menu != null;

  final List<String> _kategoriList = [
    'Udang',
    'Kepiting',
    'Ikan',
    'Cumi',
    'Kerang',
    'Minuman',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaCtrl.text = widget.menu!.namaMenu;
      _hargaCtrl.text = widget.menu!.harga.toString();
      _deskripsiCtrl.text = widget.menu!.deskripsi ?? '';
      _kategori = widget.menu!.kategori;
      _tersedia = widget.menu!.tersedia;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final menu = MenuModel(
        id: widget.menu?.id ?? '',
        namaMenu: _namaCtrl.text.trim(),
        kategori: _kategori,
        harga: int.parse(_hargaCtrl.text.replaceAll(RegExp(r'\D'), '')),
        deskripsi: _deskripsiCtrl.text.trim(),
        tersedia: _tersedia,
      );

      if (isEdit) {
        await SupabaseService.updateMenu(widget.menu!.id, menu);
      } else {
        await SupabaseService.tambahMenu(menu);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? '✅ Menu berhasil diperbarui'
                  : '✅ Menu berhasil ditambahkan',
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
      appBar: AppBar(title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Menu
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu *',
                  prefixIcon: Icon(Icons.restaurant_menu),
                  hintText: 'e.g. Udang Saus Tiram',
                ),
                validator: (v) => v!.isEmpty ? 'Nama menu wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v!),
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp) *',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'e.g. 45000',
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Harga wajib diisi';
                  if (int.tryParse(v) == null) return 'Masukkan angka valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'e.g. Udang segar dengan saus tiram spesial',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Tersedia toggle
              Card(
                child: SwitchListTile(
                  title: Text(
                    'Status Tersedia',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _tersedia
                        ? 'Menu ini tersedia untuk dipesan'
                        : 'Menu ini sedang tidak tersedia',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _tersedia,
                  onChanged: (v) => setState(() => _tersedia = v),
                  secondary: Icon(
                    _tersedia ? Icons.check_circle : Icons.cancel,
                    color: _tersedia ? Colors.green : Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Menu'),
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
