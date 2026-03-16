# 🦞 Seafood Resto - Aplikasi Pemesanan Restoran Seafood

Aplikasi mobile berbasis Flutter untuk mengelola pemesanan di dalam restoran seafood. Dibangun dengan integrasi **Supabase** sebagai backend database dan autentikasi.

---

## 📱 Deskripsi Aplikasi

Seafood Resto adalah aplikasi kasir/pemesanan untuk restoran seafood yang memungkinkan staf untuk mengelola menu dan mencatat pesanan pelanggan secara real-time. Data disimpan di cloud menggunakan Supabase sehingga dapat diakses dari perangkat manapun.

---

## ✨ Fitur Aplikasi

### 🔐 Autentikasi
- Login dengan email dan password menggunakan Supabase Auth
- Register akun baru
- Logout

### 🍽️ Manajemen Menu
- **Tambah** menu baru (nama, kategori, harga, deskripsi, status tersedia)
- **Lihat** daftar menu dengan filter berdasarkan kategori
- **Edit** informasi menu
- **Hapus** menu
- Toggle status tersedia / habis

### 📋 Manajemen Pesanan
- **Buat** pesanan baru dengan pilih menu langsung dari daftar
- **Lihat** semua pesanan dengan filter status
- **Edit** informasi pesanan
- **Hapus** pesanan
- **Ubah status** pesanan (Menunggu → Diproses → Selesai / Dibatalkan)
- Lihat detail pesanan beserta item yang dipesan

### 🎨 UI/UX
- **Light Mode & Dark Mode** toggle
- Splash screen animasi
- Filter chip untuk kategori menu dan status pesanan
- Pull to refresh

---

## 🧩 Widget yang Digunakan

| Widget | Kegunaan |
|--------|----------|
| `Scaffold` | Struktur dasar halaman |
| `AppBar` | Header aplikasi |
| `NavigationBar` | Bottom navigation antar tab |
| `ListView.builder` | Daftar menu dan pesanan |
| `Card` | Tampilan item list |
| `ListTile` | Baris item dalam list |
| `TextFormField` | Input form dengan validasi |
| `DropdownButtonFormField` | Pilih kategori menu |
| `SwitchListTile` | Toggle status tersedia |
| `FilterChip` | Filter kategori & status |
| `FloatingActionButton` | Tombol tambah |
| `ElevatedButton` | Tombol aksi utama |
| `IconButton` | Tombol edit & hapus |
| `AlertDialog` | Konfirmasi hapus |
| `SimpleDialog` | Pilih status pesanan |
| `SnackBar` | Notifikasi feedback |
| `CircularProgressIndicator` | Loading state |
| `RefreshIndicator` | Pull to refresh |
| `PopupMenuButton` | Menu logout |
| `AnimationController` | Animasi splash screen |
| `FadeTransition` | Efek fade pada splash |
| `ScaleTransition` | Efek scale pada splash |

---

## 🗄️ Struktur Database Supabase

```sql
-- Tabel menu
create table menu (
  id uuid default gen_random_uuid() primary key,
  nama_menu text not null,
  kategori text not null,
  harga integer not null,
  deskripsi text,
  tersedia boolean default true,
  created_at timestamp default now()
);

-- Tabel pesanan
create table pesanan (
  id uuid default gen_random_uuid() primary key,
  nama_pelanggan text not null,
  nomor_meja integer not null,
  catatan text,
  status text default 'Menunggu',
  total_harga integer default 0,
  created_at timestamp default now()
);

-- Tabel detail pesanan
create table detail_pesanan (
  id uuid default gen_random_uuid() primary key,
  pesanan_id uuid references pesanan(id) on delete cascade,
  menu_id uuid references menu(id),
  nama_menu text not null,
  harga integer not null,
  jumlah integer not null,
  created_at timestamp default now()
);
```

---

## 🚀 Cara Menjalankan

1. **Clone repository**
   ```bash
   git clone https://github.com/username/seafood_resto.git
   cd seafood_resto
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Buat file `.env`** di root project:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

4. **Setup Supabase** — jalankan SQL di atas di Supabase SQL Editor

5. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📁 Struktur Folder

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── models/
│   ├── menu_model.dart
│   └── pesanan_model.dart
├── services/
│   └── supabase_service.dart
└── pages/
    ├── splash_page.dart
    ├── home_page.dart
    ├── auth/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── menu/
    │   ├── menu_list_page.dart
    │   └── menu_form_page.dart
    └── pesanan/
        ├── pesanan_list_page.dart
        ├── pesanan_form_page.dart
        └── pesanan_detail_page.dart
```

---

## 🛠️ Tech Stack

- **Flutter** — UI Framework
- **Supabase** — Backend as a Service (Database + Auth)
- **flutter_dotenv** — Environment variable management
- **google_fonts** — Typography (Poppins)
- **intl** — Format mata uang Rupiah



Untuk melihat beberapa hasil screenshotnya maka ini adalah 

dari halaman login

<img width="1910" height="1068" alt="Image" src="https://github.com/user-attachments/assets/efc79842-ebeb-41f4-a80f-6b807376a07f" />

Kalau sudah berhasil memasukkan emailnya maka ini adalah tampilan webnya

<img width="1910" height="1071" alt="Image" src="https://github.com/user-attachments/assets/a3aa387c-85d5-43a7-b528-a264df3cbe04" />

Kalau ingin melihat-lihat makanan ada bisa masuk ke panel Makanan

<img width="1910" height="1071" alt="Image" src="https://github.com/user-attachments/assets/9b99f5fb-2515-453f-ab5a-2cf321a96e92" />

dan juga kalau mau melakukan edit tinggal tekan bagian icon pensil, ataupun menghapus makanan ini dengan mengkilk icon sampah

dan masuk ke panel pesanan. disini akan diperlihatkan beberapa macam jenis pesanan dan juga konfirmasinya

<img width="1910" height="1071" alt="Image" src="https://github.com/user-attachments/assets/4f334c48-8f7c-4e0d-8d57-4eb810fd97c6" />

begitu pesan sudah berhasil didapatkan maka inilah hasilnya

<img width="1910" height="1060" alt="Image" src="https://github.com/user-attachments/assets/3f5d8599-96da-442e-aab1-0db0692d939b" />

kalau ini mode light/terang

<img width="1910" height="1071" alt="Image" src="https://github.com/user-attachments/assets/b554373c-3694-41fe-8a1f-524efac75780" />

maka setelah menekan icon bulan akan mengaktifkan mode gelap/dark

<img width="1910" height="1071" alt="Image" src="https://github.com/user-attachments/assets/952af223-d14e-4cdc-a328-804db91ec04a" />
