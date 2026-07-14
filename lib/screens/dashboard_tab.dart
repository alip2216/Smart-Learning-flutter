import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../data/models/learning_project.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback onNavigateToHistory;

  const DashboardTab({super.key, required this.onNavigateToHistory});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProjects();
    });
    _startBlinking();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() { _isBlinking = true; });
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() { _isBlinking = false; });
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _fetchProjects() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ProjectProvider>().loadProjects(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _fetchProjects(),
      color: const Color(0xFF4F46E5),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // HEADER (Halo, [Nama])
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          
          // HERO SECTION: Robot AI & Stats
          SliverToBoxAdapter(
            child: _buildRobotHero(context),
          ),

          // SECTION TITLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fokus Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToHistory,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),

          // PROJECT LIST (Max 3)
          Consumer<ProjectProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.projects.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    ),
                  ),
                );
              }

              if (provider.projects.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    child: Center(
                      child: Text(
                        'Belum ada catatan, yuk buat baru!',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                );
              }

              // Ambil maksimal 3 proyek terbaru
              final recentProjects = provider.projects.take(3).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildProjectCard(recentProjects[index], context);
                    },
                    childCount: recentProjects.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom padding agar tidak tertutup bottom nav
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.user?.name ?? 'Pengguna';
        final firstName = userName.split(' ')[0];
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $firstName! 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Siap untuk belajar hal baru hari ini?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: auth.user?.profilePhotoUrl != null
                        ? Image.network(
                            auth.user!.profilePhotoUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, color: Color(0xFF4F46E5)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRobotHero(BuildContext context) {
    final userName = context.read<AuthProvider>().user?.name?.split(' ')[0] ?? 'Sobat';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A72FF), Color(0xFF7E8FFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Konten utama: Robot & Cards
            Column(
              children: [
                const SizedBox(height: 80), // Menambah ruang agar teks tidak menutupi robot
                // Robot Image
                Image.asset(
                  _isBlinking ? 'assets/images/robot_blink.png' : 'assets/images/robot.png',
                  height: 220, // Memperbesar sedikit
                  fit: BoxFit.contain,
                ),
                
                // Stat Cards (Total Proyek & Aktif)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Consumer<ProjectProvider>(
                    builder: (context, provider, _) {
                      final total = provider.projects.length;
                      final active = provider.projects.where((p) => p.status == 'aktif').length;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatMiniCard(
                              icon: Icons.library_books_rounded,
                              iconColor: Colors.amber,
                              title: 'Total Catatan',
                              value: total.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatMiniCard(
                              icon: Icons.track_changes_rounded,
                              iconColor: Colors.greenAccent,
                              title: 'Proyek Aktif',
                              value: active.toString(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Speech Bubble (Teks Tanpa Background di Kanan Kepala Robot)
            Positioned(
              top: 60, // Sejajar dengan kotak putih (kepala robot)
              right: 15, // Paling kanan
              width: 120, // Lebih sempit agar tidak menabrak kepala
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12, // Tetap kecil agar rapi di kotak
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Halo $userName!\nSaya adalah Anwar, siap menjadi mentormu!',
                        speed: const Duration(milliseconds: 60),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    isRepeatingAnimation: false,
                    displayFullTextOnTap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniCard({required IconData icon, required Color iconColor, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Color(0xFF111827), fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
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
                // Icon / Avatar project
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
                
                // Info
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
