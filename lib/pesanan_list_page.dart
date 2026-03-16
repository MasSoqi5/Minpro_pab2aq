import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'pesanan_model.dart';
import 'supabase_service.dart';
import 'pesanan_form_page.dart';
import 'pesanan_detail_page.dart';

class PesananListPage extends StatefulWidget {
  const PesananListPage({super.key});

  @override
  State<PesananListPage> createState() => _PesananListPageState();
}

class _PesananListPageState extends State<PesananListPage> {
  List<PesananModel> _pesananList = [];
  bool _loading = true;
  String _filterStatus = 'Semua';

  final List<String> _statusList = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
    'Dibatalkan',
  ];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getPesanan();
      setState(() => _pesananList = data);
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

  List<PesananModel> get _filtered {
    if (_filterStatus == 'Semua') return _pesananList;
    return _pesananList.where((p) => p.status == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu':
        return Icons.schedule;
      case 'Diproses':
        return Icons.restaurant;
      case 'Selesai':
        return Icons.check_circle;
      case 'Dibatalkan':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _hapusPesanan(PesananModel pesanan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text(
          'Hapus pesanan dari "${pesanan.namaPelanggan}" - Meja ${pesanan.nomorMeja}?',
        ),
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
        await SupabaseService.hapusPesanan(pesanan.id);
        _loadPesanan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dihapus'),
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

  Future<void> _ubahStatus(PesananModel pesanan) async {
    final status = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Ubah Status Pesanan'),
        children: ['Menunggu', 'Diproses', 'Selesai', 'Dibatalkan']
            .map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(s),
                      color: _getStatusColor(s),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(s),
                    if (s == pesanan.status)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.check, size: 16, color: Colors.green),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (status != null && status != pesanan.status) {
      await SupabaseService.updateStatusPesanan(pesanan.id, status);
      _loadPesanan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter status
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _statusList.length,
            itemBuilder: (ctx, i) {
              final status = _statusList[i];
              final selected = _filterStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterStatus = status),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pesanan',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPesanan,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final pesanan = _filtered[i];
                      final statusColor = _getStatusColor(pesanan.status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PesananDetailPage(pesanan: pesanan),
                              ),
                            );
                            _loadPesanan();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0077B6,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Meja ${pesanan.nomorMeja}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0077B6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        pesanan.namaPelanggan,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _ubahStatus(pesanan),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(pesanan.status),
                                              size: 14,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              pesanan.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: statusColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (pesanan.catatan != null &&
                                    pesanan.catatan!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.note_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          pesanan.catatan!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currencyFormat.format(pesanan.totalHarga),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PesananFormPage(
                                                  pesanan: pesanan,
                                                ),
                                              ),
                                            );
                                            _loadPesanan();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                          onPressed: () =>
                                              _hapusPesanan(pesanan),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (pesanan.createdAt != null)
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy, HH:mm',
                                      'id_ID',
                                    ).format(pesanan.createdAt!.toLocal()),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
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
              label: const Text('Buat Pesanan Baru'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PesananFormPage()),
                );
                _loadPesanan();
              },
            ),
          ),
        ),
      ],
    );
  }
}
