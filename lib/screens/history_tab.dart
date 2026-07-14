import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../data/models/learning_project.dart';
import 'project_detail_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Semua Catatan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Expanded(
          child: Consumer<ProjectProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.projects.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                );
              }

              if (provider.projects.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Belum ada catatan yang tersimpan.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 100),
                itemCount: provider.projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(provider.projects[index], context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(LearningProject project, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: project.status == 'aktif' ? const Color(0xFF057A55) : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            project.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: project.status == 'aktif' ? const Color(0xFF03543F) : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
