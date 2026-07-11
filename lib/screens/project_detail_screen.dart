import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/learning_project.dart';
import '../data/models/learning_log.dart';
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';
import '../providers/project_provider.dart';
import '../utils/custom_alert.dart';
import 'chat_tab.dart';

class ProjectDetailScreen extends StatefulWidget {
  final LearningProject project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLogs();
    });
  }

  void _fetchLogs() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<LogProvider>().loadLogs(token, widget.project.id);
    }
  }

  void _showAddOrEditLogBottomSheet({LearningLog? existingLog}) {
    final noteController = TextEditingController(text: existingLog?.note ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existingLog == null ? 'Catatan Belajar Baru' : 'Edit Catatan',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (existingLog == null)
                const Text(
                  'Catat kemajuan belajar Anda hari ini.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Contoh: Hari ini saya belajar tentang State Management...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<LogProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final note = noteController.text.trim();
                            if (note.isEmpty) {
                              CustomAlert.showWarning(context, 'Peringatan', subtitle: 'Catatan tidak boleh kosong');
                              return;
                            }

                            final token = context.read<AuthProvider>().token;
                            if (token != null) {
                              final date = DateTime.now().toIso8601String().split('T')[0];

                              if (existingLog == null) {
                                // Create (tanpa AI Response lagi karena pindah ke tab Mentor)
                                final success = await provider.createLog(token, widget.project.id, note, date);
                                if (mounted) {
                                  Navigator.pop(context);
                                  if (success != null) { // Walau function createLog lama mengembalikan string, kita anggap success != null berarti berhasil disimpan
                                    CustomAlert.showSuccess(context, 'Berhasil!', subtitle: 'Catatan berhasil disimpan');
                                  } else {
                                    CustomAlert.showError(context, 'Gagal!', subtitle: 'Gagal menyimpan catatan');
                                  }
                                }
                              } else {
                                // Update
                                final success = await provider.updateLog(token, widget.project.id, existingLog.id, note, date);
                                if (mounted) {
                                  Navigator.pop(context);
                                  if (success) {
                                    CustomAlert.showSuccess(context, 'Berhasil!', subtitle: 'Catatan diperbarui');
                                  } else {
                                    CustomAlert.showError(context, 'Gagal!', subtitle: 'Gagal memperbarui catatan');
                                  }
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(existingLog == null ? 'Simpan Catatan' : 'Simpan Perubahan', 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(LearningLog log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Catatan yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final success = await context.read<LogProvider>().deleteLog(token, widget.project.id, log.id);
                if (mounted) {
                  if (success) {
                    CustomAlert.showSuccess(context, 'Berhasil!', subtitle: 'Catatan dihapus');
                  } else {
                    CustomAlert.showError(context, 'Gagal!', subtitle: 'Gagal menghapus catatan');
                  }
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(widget.project.title, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF111827)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Hapus Proyek',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Proyek?'),
                    content: const Text('Semua catatan dan riwayat obrolan AI di proyek ini akan terhapus secara permanen.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final token = context.read<AuthProvider>().token;
                          if (token != null) {
                            // Import ProjectProvider required at the top
                            final success = await context.read<ProjectProvider>().deleteProject(token, widget.project.id);
                            if (mounted) {
                              if (success) {
                                Navigator.pop(context); // Kembali ke HomeScreen
                                CustomAlert.showSuccess(context, 'Berhasil!', subtitle: 'Proyek dihapus');
                              } else {
                                CustomAlert.showError(context, 'Gagal!', subtitle: 'Gagal menghapus proyek');
                              }
                            }
                          }
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4F46E5),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Catatan', icon: Icon(Icons.library_books)),
              Tab(text: 'Anwar', icon: Icon(Icons.smart_toy_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: CATATAN (LOGS)
            _buildLogsTab(),

            // TAB 2: AI MENTOR (CHAT)
            ChatTab(project: widget.project),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<LogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.logs.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
          }

          if (provider.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Catatan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tulis jurnal belajarmu hari ini!',
                    style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchLogs();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.logs.length,
              itemBuilder: (context, index) {
                final log = provider.logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Text(
                              log.progressDate,
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddOrEditLogBottomSheet(existingLog: log);
                                } else if (value == 'delete') {
                                  _confirmDelete(log);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                              child: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          log.note,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF111827), height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditLogBottomSheet(),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: const Text(
          'Catat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
