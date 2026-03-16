import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'menu_list_page.dart';
import 'pesanan_list_page.dart';
import 'supabase_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [PesananListPage(), MenuListPage()];

  @override
  Widget build(BuildContext context) {
    final appState = SeafoodApp.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🦞 '),
            Text(_currentIndex == 0 ? 'Daftar Pesanan' : 'Menu Seafood'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: appState?.isDark ?? false ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(
              appState?.isDark ?? false ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => appState?.toggleTheme(),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ),
            ],
            onSelected: (val) async {
              if (val == 'logout') {
                await SupabaseService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
