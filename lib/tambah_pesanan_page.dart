import 'package:flutter/material.dart';
import '/pesanan.dart';

class TambahPesananPage extends StatefulWidget {
  @override
  _TambahPesananPageState createState() => _TambahPesananPageState();
}

class _TambahPesananPageState extends State<TambahPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final menuController = TextEditingController();
  final jumlahController = TextEditingController();
  final mejaController = TextEditingController();

  void simpanData() {
    if (_formKey.currentState!.validate()) {
      final pesanan = Pesanan(
        namaPelanggan: namaController.text,
        namaMenu: menuController.text,
        jumlah: jumlahController.text,
        nomorMeja: mejaController.text,
      );

      Navigator.pop(context, pesanan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Pesanan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Pelanggan"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: menuController,
                decoration: InputDecoration(labelText: "Menu Seafood"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: jumlahController,
                decoration: InputDecoration(labelText: "Jumlah Pesanan"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: mejaController,
                decoration: InputDecoration(labelText: "Nomor Meja"),
                validator: (value) =>
                    value!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: simpanData, child: Text("Simpan")),
            ],
          ),
        ),
      ),
    );
  }
}
