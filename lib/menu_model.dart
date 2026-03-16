// lib/models/menu_model.dart
class MenuModel {
  final String id;
  final String namaMenu;
  final String kategori;
  final int harga;
  final String? deskripsi;
  final bool tersedia;
  final DateTime? createdAt;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    this.deskripsi,
    this.tersedia = true,
    this.createdAt,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      namaMenu: json['nama_menu'],
      kategori: json['kategori'],
      harga: json['harga'],
      deskripsi: json['deskripsi'],
      tersedia: json['tersedia'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_menu': namaMenu,
      'kategori': kategori,
      'harga': harga,
      'deskripsi': deskripsi,
      'tersedia': tersedia,
    };
  }
}
