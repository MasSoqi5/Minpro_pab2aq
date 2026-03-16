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
