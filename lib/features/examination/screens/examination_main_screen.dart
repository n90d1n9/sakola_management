import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../states/exam_providers.dart';
import '../models/exam_period.dart';
import '../models/exam_schedule.dart';
import '../../../core/theme/app_colors.dart';
import 'exam_period_form_screen.dart';
import 'exam_schedule_form_screen.dart';

/// Enhanced Examination Dashboard with complete CRUD operations
class ExaminationDashboardScreen extends ConsumerStatefulWidget {
  const ExaminationDashboardScreen({super.key});

  @override
  ConsumerState<ExaminationDashboardScreen> createState() => _ExaminationDashboardScreenState();
}

class _ExaminationDashboardScreenState extends ConsumerState<ExaminationDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriodFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(examPeriodNotifierProvider.notifier).loadExamPeriods();
      ref.read(examScheduleNotifierProvider.notifier).loadExamSchedules();
      ref.read(examResultNotifierProvider.notifier).loadExamResults();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await ref.read(examPeriodNotifierProvider.notifier).loadExamPeriods();
    await ref.read(examScheduleNotifierProvider.notifier).loadExamSchedules();
    await ref.read(examResultNotifierProvider.notifier).loadExamResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ujian & Penilaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.date_range), text: 'Periode Ujian'),
            Tab(icon: Icon(Icons.schedule), text: 'Jadwal Ujian'),
            Tab(icon: Icon(Icons.analytics), text: 'Nilai'),
            Tab(icon: Icon(Icons.description), text: 'Rapor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPeriodsTab(),
          _buildSchedulesTab(),
          _buildResultsTab(),
          _buildReportCardsTab(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => _navigateToPeriodForm(),
          icon: const Icon(Icons.add),
          label: const Text('Periode Baru'),
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _navigateToScheduleForm(),
          icon: const Icon(Icons.add),
          label: const Text('Jadwal Baru'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _navigateToPeriodForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExamPeriodFormScreen()),
    );
  }

  void _navigateToScheduleForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExamScheduleFormScreen()),
    );
  }

  Widget _buildPeriodsTab() {
    final periodState = ref.watch(examPeriodNotifierProvider);

    if (periodState.isEmpty && periodState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.date_range_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada periode ujian', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _navigateToPeriodForm,
              icon: const Icon(Icons.add),
              label: const Text('Buat Periode Pertama'),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    var periods = periodState;

    // Filter by status
    if (_selectedPeriodFilter != 'all') {
      periods = periods.where((p) {
        if (_selectedPeriodFilter == 'active') {
          return p.startDate.isBefore(now) && p.endDate.isAfter(now);
        } else if (_selectedPeriodFilter == 'upcoming') {
          return p.startDate.isAfter(now);
        } else if (_selectedPeriodFilter == 'completed') {
          return p.endDate.isBefore(now);
        }
        return true;
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Aktif', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Akan Datang', 'upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', 'completed'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final period = periods[index];
              final isActive = period.startDate.isBefore(now) && period.endDate.isAfter(now);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    child: Icon(
                      isActive ? Icons.check_circle : Icons.event,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(
                    '${period.examType.name.toUpperCase()} - ${period.academicYear}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(period.description),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(period.startDate)} - ${DateFormat('dd MMM yyyy').format(period.endDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      isActive ? 'AKTIF' : (period.startDate.isAfter(now) ? 'AKAN DATANG' : 'SELESAI'),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: isActive ? Colors.green : (period.startDate.isAfter(now) ? Colors.orange : Colors.grey),
                    padding: EdgeInsets.zero,
                  ),
                  onTap: () => _showPeriodDetail(period),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedPeriodFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPeriodFilter = value);
      },
    );
  }

  Widget _buildSchedulesTab() {
    final scheduleState = ref.watch(examScheduleNotifierProvider);

    if (scheduleState.isEmpty && scheduleState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada jadwal ujian', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _navigateToScheduleForm,
              icon: const Icon(Icons.add),
              label: const Text('Buat Jadwal Pertama'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scheduleState.length,
      itemBuilder: (context, index) {
        final schedule = scheduleState[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: const Icon(Icons.subject, color: Colors.blue),
            ),
            title: Text(schedule.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kelas: ${schedule.gradeLevel}'),
                Text(
                  '${DateFormat('EEEE, dd MMM yyyy').format(schedule.date)} | ${schedule.startTime} - ${schedule.endTime}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (schedule.room.isNotEmpty) Text('Ruang: ${schedule.room}'),
              ],
            ),
            trailing: Text(
              schedule.teacherName,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsTab() {
    final resultState = ref.watch(examResultNotifierProvider);

    if (resultState.isEmpty && resultState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada nilai ujian', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultState.length,
      itemBuilder: (context, index) {
        final result = resultState[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGradeColor(result.score).withOpacity(0.2),
              child: Text(
                _scoreToGrade(result.score),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(result.score),
                ),
              ),
            ),
            title: Text(result.studentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.subject} - ${result.examType.name}'),
                Text('Skor: ${result.score.toStringAsFixed(1)}'),
              ],
            ),
            trailing: Text(
              DateFormat('dd MMM yyyy').format(result.examDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCardsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Fitur rapor dalam pengembangan', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showPeriodDetail(ExamPeriod period) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      period.examType.name.toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(period.academicYear),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDetailRow('Deskripsi', period.description),
                _buildDetailRow(
                  'Periode',
                  '${DateFormat('dd MMMM yyyy').format(period.startDate)} - ${DateFormat('dd MMMM yyyy').format(period.endDate)}',
                ),
                _buildDetailRow('Status', period.isActive ? 'Aktif' : 'Tidak Aktif'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _scoreToGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }
}
