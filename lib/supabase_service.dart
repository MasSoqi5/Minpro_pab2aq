import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_model.dart';
import 'pesanan_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ===================== AUTH =====================

  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  // ===================== MENU =====================

  static Future<List<MenuModel>> getMenu() async {
    final response = await _client
        .from('menu')
        .select()
        .order('kategori', ascending: true);
    return (response as List).map((e) => MenuModel.fromJson(e)).toList();
  }

  static Future<void> tambahMenu(MenuModel menu) async {
    await _client.from('menu').insert(menu.toJson());
  }

  static Future<void> updateMenu(String id, MenuModel menu) async {
    await _client.from('menu').update(menu.toJson()).eq('id', id);
  }

  static Future<void> hapusMenu(String id) async {
    await _client.from('menu').delete().eq('id', id);
  }

  // ===================== PESANAN =====================

  static Future<List<PesananModel>> getPesanan() async {
    final response = await _client
        .from('pesanan')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => PesananModel.fromJson(e)).toList();
  }

  static Future<String> tambahPesanan(PesananModel pesanan) async {
    final response = await _client
        .from('pesanan')
        .insert(pesanan.toJson())
        .select()
        .single();
    return response['id'];
  }

  static Future<void> updateStatusPesanan(String id, String status) async {
    await _client.from('pesanan').update({'status': status}).eq('id', id);
  }

  static Future<void> updatePesanan(String id, PesananModel pesanan) async {
    await _client.from('pesanan').update(pesanan.toJson()).eq('id', id);
  }

  static Future<void> hapusPesanan(String id) async {
    await _client.from('pesanan').delete().eq('id', id);
  }

  // ===================== DETAIL PESANAN =====================

  static Future<List<DetailPesananModel>> getDetailPesanan(
    String pesananId,
  ) async {
    final response = await _client
        .from('detail_pesanan')
        .select()
        .eq('pesanan_id', pesananId);
    return (response as List)
        .map((e) => DetailPesananModel.fromJson(e))
        .toList();
  }

  static Future<void> tambahDetailPesanan(
    String pesananId,
    String menuId,
    String namaMenu,
    int harga,
    int jumlah,
  ) async {
    await _client.from('detail_pesanan').insert({
      'pesanan_id': pesananId,
      'menu_id': menuId,
      'nama_menu': namaMenu,
      'harga': harga,
      'jumlah': jumlah,
    });
  }

  static Future<void> updateTotalHarga(String pesananId, int total) async {
    await _client
        .from('pesanan')
        .update({'total_harga': total})
        .eq('id', pesananId);
  }
}
