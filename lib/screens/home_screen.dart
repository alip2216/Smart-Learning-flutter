import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../utils/custom_alert.dart';

import 'dashboard_tab.dart';
import 'explore_tab.dart';
import 'history_tab.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk setiap tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardTab(
        onNavigateToHistory: () => _onItemTapped(3),
      ),
      const ExploreTab(),
      const SizedBox(), // Placeholder untuk tombol tengah (FAB)
      const HistoryTab(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) return; // Jangan lakukan apa-apa jika tap area kosong FAB
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddProjectBottomSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Proyek Belajar Baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tentukan topik apa yang ingin Anda pelajari kali ini.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Topik (contoh: Belajar Flutter)',
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF4F46E5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi / Target (Opsional)',
                  prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF4F46E5)),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Consumer<ProjectProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) {
                              CustomAlert.showWarning(context, 'Peringatan', subtitle: 'Judul tidak boleh kosong');
                              return;
                            }

                            final token = context.read<AuthProvider>().token;
                            if (token != null) {
                              final success = await provider.createProject(
                                    token,
                                    title,
                                    descController.text.trim(),
                                  );
                              if (success && mounted) {
                                Navigator.pop(context);
                                CustomAlert.showSuccess(context, 'Berhasil!', subtitle: 'Proyek berhasil ditambahkan!');
                                // Pindah kembali ke tab Beranda jika sukses tambah proyek
                                setState(() {
                                  _selectedIndex = 0;
                                });
                              } else if (mounted) {
                                CustomAlert.showError(context, 'Gagal!', subtitle: 'Gagal menambahkan proyek');
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Buat Proyek', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      // FAB di tengah (Sembunyikan saat keyboard muncul)
      floatingActionButton: isKeyboardOpen ? null : FloatingActionButton(
        onPressed: _showAddProjectBottomSheet,
        backgroundColor: const Color(0xFF8B9DFF), // Warna biru pastel sesuai permintaan
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Custom Bottom App Bar (Sembunyikan saat keyboard terbuka)
      bottomNavigationBar: isKeyboardOpen ? const SizedBox.shrink() : BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kiri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                  const SizedBox(width: 24),
                  _buildNavItem(icon: Icons.smart_toy_rounded, label: 'Explore', index: 1), // Menggunakan icon robot
                ],
              ),
              // Kanan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(icon: Icons.history_rounded, label: 'Catatan', index: 3),
                  const SizedBox(width: 24),
                  _buildNavItem(icon: Icons.person_rounded, label: 'Profile', index: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF);

    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
