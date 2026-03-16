import 'package:flutter/material.dart';
import '/pesanan.dart';
import 'tambah_pesanan_page.dart';
import 'edit_pesanan_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pesanan> daftarPesanan = [];

  void tambahPesanan(Pesanan pesanan) {
    setState(() {
      daftarPesanan.add(pesanan);
    });
  }

  void hapusPesanan(int index) {
    setState(() {
      daftarPesanan.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Pesanan berhasil dihapus")));
  }

  void updatePesanan(int index, Pesanan pesananBaru) {
    setState(() {
      daftarPesanan[index] = pesananBaru;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🦐 SeaFood Orders")),
      body: ListView.builder(
        itemCount: daftarPesanan.length,
        itemBuilder: (context, index) {
          final pesanan = daftarPesanan[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(
                "https://tse4.mm.bing.net/th/id/OIP.hd4D6ggf74V4Yf-4MTDcAwHaJQ?pid=Api&P=0&h=180",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
              title: Text(pesanan.namaPelanggan),
              subtitle: Text(
                "${pesanan.namaMenu} | ${pesanan.jumlah} porsi | Meja ${pesanan.nomorMeja}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final hasil = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditPesananPage(pesanan: pesanan),
                        ),
                      );

                      if (hasil != null) {
                        updatePesanan(index, hasil);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusPesanan(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahPesananPage()),
          );

          if (hasil != null) {
            tambahPesanan(hasil);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
