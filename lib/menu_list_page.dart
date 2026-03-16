import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_model.dart';
import 'supabase_service.dart';
import 'menu_form_page.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  List<MenuModel> _menus = [];
  bool _loading = true;
  String _filterKategori = 'Semua';

  final List<String> _kategoriList = [
    'Semua',
    'Udang',
    'Kepiting',
    'Ikan',
    'Cumi',
    'Kerang',
    'Minuman',
    'Lainnya',
  ];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getMenu();
      setState(() => _menus = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  List<MenuModel> get _filteredMenus {
    if (_filterKategori == 'Semua') return _menus;
    return _menus.where((m) => m.kategori == _filterKategori).toList();
  }

  Future<void> _hapusMenu(MenuModel menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Hapus "${menu.namaMenu}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await SupabaseService.hapusMenu(menu.id);
        _loadMenu();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
        }
      }
    }
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case 'Udang':
        return Colors.orange;
      case 'Kepiting':
        return Colors.red;
      case 'Ikan':
        return Colors.blue;
      case 'Cumi':
        return Colors.purple;
      case 'Kerang':
        return Colors.teal;
      case 'Minuman':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getKategoriEmoji(String kategori) {
    switch (kategori) {
      case 'Udang':
        return '🍤';
      case 'Kepiting':
        return '🦀';
      case 'Ikan':
        return '🐟';
      case 'Cumi':
        return '🦑';
      case 'Kerang':
        return '🦪';
      case 'Minuman':
        return '🥤';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chip
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _kategoriList.length,
            itemBuilder: (ctx, i) {
              final kat = _kategoriList[i];
              final selected = _filterKategori == kat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(kat),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterKategori = kat),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMenus.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🍽️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada menu',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMenu,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredMenus.length,
                    itemBuilder: (ctx, i) {
                      final menu = _filteredMenus[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getKategoriColor(
                                menu.kategori,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _getKategoriEmoji(menu.kategori),
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  menu.namaMenu,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: menu.tersedia
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  menu.tersedia ? 'Tersedia' : 'Habis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: menu.tersedia
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormat.format(menu.harga),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              if (menu.deskripsi != null &&
                                  menu.deskripsi!.isNotEmpty)
                                Text(
                                  menu.deskripsi!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Chip(
                                label: Text(
                                  menu.kategori,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: _getKategoriColor(
                                  menu.kategori,
                                ).withOpacity(0.15),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MenuFormPage(menu: menu),
                                    ),
                                  );
                                  _loadMenu();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _hapusMenu(menu),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Menu Baru'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuFormPage()),
                );
                _loadMenu();
              },
            ),
          ),
        ),
      ],
    );
  }
}
