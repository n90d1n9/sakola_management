import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/curriculum_providers.dart';

/// Main screen for Curriculum Management
/// Tab-based interface for Curriculum Maps and Lesson Plans
class CurriculumMainScreen extends ConsumerStatefulWidget {
  @override
  _CurriculumMainScreenState createState() => _CurriculumMainScreenState();
}

class _CurriculumMainScreenState extends ConsumerState<CurriculumMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(curriculumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Kurikulum'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.map_rounded), text: 'Peta Kurikulum'),
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'RPP/Modul Ajar'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(curriculumProvider.notifier).init(),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearch(),
          ),
        ],
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurriculumMapsTab(),
                _buildLessonPlansTab(),
              ],
            ),
    );
  }

  Widget _buildCurriculumMapsTab() {
    final curriculumMaps = ref.watch(filteredCurriculumMapsProvider);

    if (curriculumMaps.isEmpty) {
      return _buildEmptyState(
        Icons.map_outlined,
        'Belum ada Peta Kurikulum',
        'Tambahkan peta kurikulum untuk memulai',
        'Tambah Peta Kurikulum',
        () => _showCurriculumMapForm(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(curriculumProvider.notifier).loadAllData(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: curriculumMaps.length,
        itemBuilder: (context, index) {
          final map = curriculumMaps[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.map_rounded, color: Colors.blue),
              ),
              title: Text(
                map.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('${map.educationLevel} • ${map.semester}'),
                  Text(map.academicYear),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Lihat Detail'),
                    onTap: () => _viewCurriculumMap(map.id),
                  ),
                  PopupMenuItem(
                    child: Text('Edit'),
                    onTap: () => _editCurriculumMap(map),
                  ),
                  PopupMenuItem(
                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteCurriculumMap(map.id),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonPlansTab() {
    final lessonPlans = ref.watch(filteredLessonPlansProvider);

    if (lessonPlans.isEmpty) {
      return _buildEmptyState(
        Icons.edit_note_outlined,
        'Belum ada RPP/Modul Ajar',
        'Buat perangkat pembelajaran untuk mulai mengajar',
        'Tambah RPP/Modul Ajar',
        () => _showLessonPlanForm(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(curriculumProvider.notifier).loadAllData(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: lessonPlans.length,
        itemBuilder: (context, index) {
          final plan = lessonPlans[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.edit_note_rounded, color: Colors.green),
              ),
              title: Text(
                plan.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('${plan.subjectName} • Minggu ${plan.weekNumber}'),
                  Text('Fase ${plan.phase} • ${_formatSemester(plan.semester)}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Lihat Detail'),
                    onTap: () => _viewLessonPlan(plan.id),
                  ),
                  PopupMenuItem(
                    child: Text('Edit'),
                    onTap: () => _editLessonPlan(plan),
                  ),
                  PopupMenuItem(
                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteLessonPlan(plan.id),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle,
    String actionLabel,
    VoidCallback onAction,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: CurriculumSearchDelegate(_tabController.index),
    );
  }

  void _showCurriculumMapForm() {
    // TODO: Implement form dialog/screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Form Peta Kurikulum - Coming Soon')),
    );
  }

  void _showLessonPlanForm() {
    // TODO: Implement form dialog/screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Form RPP/Modul Ajar - Coming Soon')),
    );
  }

  void _viewCurriculumMap(String id) {
    // Navigate to detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View Curriculum Map: $id')),
    );
  }

  void _editCurriculumMap(dynamic map) {
    // TODO: Open edit form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${map.name}')),
    );
  }

  void _deleteCurriculumMap(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Peta Kurikulum?'),
        content: Text('Apakah Anda yakin ingin menghapus peta kurikulum ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(curriculumProvider.notifier).deleteCurriculumMap(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Peta kurikulum berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _viewLessonPlan(String id) {
    // Navigate to detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View Lesson Plan: $id')),
    );
  }

  void _editLessonPlan(dynamic plan) {
    // TODO: Open edit form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${plan.title}')),
    );
  }

  void _deleteLessonPlan(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus RPP/Modul Ajar?'),
        content: Text('Apakah Anda yakin ingin menghapus RPP/modul ajar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(curriculumProvider.notifier).deleteLessonPlan(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('RPP/modul ajar berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatSemester(String semester) {
    return semester == '1' ? 'Ganjil' : 'Genap';
  }
}

/// Search delegate for curriculum content
class CurriculumSearchDelegate extends SearchDelegate {
  final int initialTabIndex;

  CurriculumSearchDelegate(this.initialTabIndex);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text('Masukkan kata kunci untuk mencari'),
      );
    }

    // Search in both curriculum maps and lesson plans
    final notifier = read(curriculumProvider.notifier);
    
    if (initialTabIndex == 0) {
      notifier.searchCurriculumMaps(query);
      final results = read(filteredCurriculumMapsProvider);
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final map = results[index];
          return ListTile(
            title: Text(map.name),
            subtitle: Text(map.academicYear),
            onTap: () {
              // Navigate to detail
              close(context, null);
            },
          );
        },
      );
    } else {
      notifier.searchLessonPlans(query);
      final results = read(filteredLessonPlansProvider);
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final plan = results[index];
          return ListTile(
            title: Text(plan.title),
            subtitle: Text('${plan.subjectName} • Minggu ${plan.weekNumber}'),
            onTap: () {
              // Navigate to detail
              close(context, null);
            },
          );
        },
      );
    }
  }
}
