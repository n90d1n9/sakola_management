import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../states/curriculum_providers.dart';

/// Dashboard for Curriculum Module
/// Shows overview of curriculum maps, lesson plans, and quick actions
class CurriculumDashboard extends ConsumerStatefulWidget {
  @override
  _CurriculumDashboardState createState() => _CurriculumDashboardState();
}

class _CurriculumDashboardState extends ConsumerState<CurriculumDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(curriculumProvider);
    final stats = state.statistics;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Kurikulum'),
        subtitle: Text('Kurikulum Merdeka & Perangkat Pembelajaran'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(curriculumProvider.notifier).init(),
          ),
        ],
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${state.error}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(curriculumProvider.notifier).init(),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(curriculumProvider.notifier).init(),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Cards
                        _buildStatsCards(stats),
                        
                        SizedBox(height: 24),
                        
                        // Quick Actions
                        _buildQuickActions(),
                        
                        SizedBox(height: 24),
                        
                        // Recent Curriculum Maps
                        _buildRecentCurriculumMaps(),
                        
                        SizedBox(height: 24),
                        
                        // Recent Lesson Plans
                        _buildRecentLessonPlans(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic>? stats) {
    if (stats == null) {
      return Center(child: CircularProgressIndicator());
    }

    final totalMaps = stats['totalCurriculumMaps'] ?? 0;
    final totalPlans = stats['totalLessonPlans'] ?? 0;
    final mapsByType = stats['mapsByType'] as Map<String, int>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Kurikulum',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Peta Kurikulum',
                totalMaps.toString(),
                Icons.map_rounded,
                Colors.blue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'RPP/Modul Ajar',
                totalPlans.toString(),
                Icons.edit_note_rounded,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Curriculum Type Breakdown
        if (mapsByType.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis Kurikulum',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  ...mapsByType.entries.map((entry) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatCurriculumType(entry.key)),
                        Chip(
                          label: Text('${entry.value}'),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              'Peta Kurikulum Baru',
              Icons.add_chart_rounded,
              Colors.blue,
              () => context.go('/curriculum/main?action=new_map'),
            ),
            _buildActionButton(
              'RPP/Modul Ajar Baru',
              Icons.note_add_rounded,
              Colors.green,
              () => context.go('/curriculum/main?action=new_plan'),
            ),
            _buildActionButton(
              'Lihat Semua',
              Icons.list_rounded,
              Colors.orange,
              () => context.go('/curriculum/main'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCurriculumMaps() {
    final curriculumMaps = ref.watch(filteredCurriculumMapsProvider);
    final recentMaps = curriculumMaps.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Peta Kurikulum Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.go('/curriculum/main'),
              child: Text('Lihat Semua'),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (recentMaps.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada peta kurikulum',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentMaps.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final map = recentMaps[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.map_rounded, color: Colors.blue),
                  ),
                  title: Text(map.name),
                  subtitle: Text(
                    '${_formatCurriculumType(map.type.toString().split('.').last)} • ${map.academicYear}',
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.go('/curriculum/map/${map.id}'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentLessonPlans() {
    final lessonPlans = ref.watch(filteredLessonPlansProvider);
    final recentPlans = lessonPlans.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RPP/Modul Ajar Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.go('/curriculum/main'),
              child: Text('Lihat Semua'),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (recentPlans.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.edit_note_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada RPP/Modul Ajar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentPlans.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final plan = recentPlans[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(Icons.edit_note_rounded, color: Colors.green),
                  ),
                  title: Text(plan.title),
                  subtitle: Text(
                    '${plan.subjectName} • Minggu ${plan.weekNumber}',
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.go('/curriculum/lesson/${plan.id}'),
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatCurriculumType(String type) {
    switch (type) {
      case 'kurikulumMerdeka':
        return 'Kurikulum Merdeka';
      case 'kurikulum2013':
        return 'K-13';
      case 'kurikulumTingkatSatuanPendidikan':
        return 'KTSP';
      case 'international':
        return 'Internasional';
      case 'islamic':
        return 'Pondok Pesantren';
      default:
        return type;
    }
  }
}
