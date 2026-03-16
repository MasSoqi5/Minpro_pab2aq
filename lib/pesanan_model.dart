class PesananModel {
  final String id;
  final String namaPelanggan;
  final int nomorMeja;
  final String? catatan;
  final String status;
  final int totalHarga;
  final DateTime? createdAt;

  PesananModel({
    required this.id,
    required this.namaPelanggan,
    required this.nomorMeja,
    this.catatan,
    this.status = 'Menunggu',
    this.totalHarga = 0,
    this.createdAt,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      id: json['id'],
      namaPelanggan: json['nama_pelanggan'],
      nomorMeja: json['nomor_meja'],
      catatan: json['catatan'],
      status: json['status'] ?? 'Menunggu',
      totalHarga: json['total_harga'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_pelanggan': namaPelanggan,
      'nomor_meja': nomorMeja,
      'catatan': catatan,
      'status': status,
      'total_harga': totalHarga,
    };
  }
}

class DetailPesananModel {
  final String id;
  final String pesananId;
  final String menuId;
  final String namaMenu;
  final int harga;
  final int jumlah;

  DetailPesananModel({
    required this.id,
    required this.pesananId,
    required this.menuId,
    required this.namaMenu,
    required this.harga,
    required this.jumlah,
  });

  int get subtotal => harga * jumlah;

  factory DetailPesananModel.fromJson(Map<String, dynamic> json) {
    return DetailPesananModel(
      id: json['id'],
      pesananId: json['pesanan_id'],
      menuId: json['menu_id'],
      namaMenu: json['nama_menu'],
      harga: json['harga'],
      jumlah: json['jumlah'],
    );
  }
}
