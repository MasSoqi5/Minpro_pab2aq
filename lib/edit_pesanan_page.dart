import 'package:flutter/material.dart';
import '/pesanan.dart';

class EditPesananPage extends StatefulWidget {
  final Pesanan pesanan;

  EditPesananPage({required this.pesanan});

  @override
  _EditPesananPageState createState() => _EditPesananPageState();
}

class _EditPesananPageState extends State<EditPesananPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController menuController;
  late TextEditingController jumlahController;
  late TextEditingController mejaController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.pesanan.namaPelanggan);
    menuController = TextEditingController(text: widget.pesanan.namaMenu);
    jumlahController = TextEditingController(text: widget.pesanan.jumlah);
    mejaController = TextEditingController(text: widget.pesanan.nomorMeja);
  }

  void updateData() {
    if (_formKey.currentState!.validate()) {
      final pesananBaru = Pesanan(
        namaPelanggan: namaController.text,
        namaMenu: menuController.text,
        jumlah: jumlahController.text,
        nomorMeja: mejaController.text,
      );

      Navigator.pop(context, pesananBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Pesanan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Pelanggan"),
              ),
              TextFormField(
                controller: menuController,
                decoration: InputDecoration(labelText: "Menu Seafood"),
              ),
              TextFormField(
                controller: jumlahController,
                decoration: InputDecoration(labelText: "Jumlah Pesanan"),
              ),
              TextFormField(
                controller: mejaController,
                decoration: InputDecoration(labelText: "Nomor Meja"),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: updateData, child: Text("Update")),
            ],
          ),
        ),
      ),
    );
  }
}
