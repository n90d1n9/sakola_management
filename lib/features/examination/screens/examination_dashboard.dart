import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/features/features_base.dart';
import '../models/exam_period.dart';
import '../models/exam_schedule.dart';
import '../states/exam_providers.dart';
import '../services/examination_service.dart';

/// Examination Feature Module Registration
class ExaminationFeature extends FeatureModule {
  @override
  String get name => 'Examination';

  @override
  String get description => 'Manage exam periods, schedules, results, and report cards';

  @override
  IconData get icon => Icons.school_rounded;

  @override
  List<FeatureRoute> get routes => [
        FeatureRoute(
          path: '/examination',
          name: 'Examination Dashboard',
          // pageBuilder: (context) => const ExaminationDashboardScreen(),
          permissions: ['admin', 'teacher', 'academic_staff'],
        ),
        FeatureRoute(
          path: '/examination/periods',
          name: 'Exam Periods',
          // pageBuilder: (context) => const ExamPeriodListScreen(),
          permissions: ['admin', 'academic_staff'],
        ),
        FeatureRoute(
          path: '/examination/schedules',
          name: 'Exam Schedules',
          // pageBuilder: (context) => const ExamScheduleListScreen(),
          permissions: ['admin', 'teacher', 'academic_staff'],
        ),
        FeatureRoute(
          path: '/examination/results',
          name: 'Exam Results',
          // pageBuilder: (context) => const ExamResultsScreen(),
          permissions: ['admin', 'teacher'],
        ),
        FeatureRoute(
          path: '/examination/report-cards',
          name: 'Report Cards',
          // pageBuilder: (context) => const ReportCardsScreen(),
          permissions: ['admin', 'teacher', 'academic_staff'],
        ),
        FeatureRoute(
          path: '/examination/question-bank',
          name: 'Question Bank',
          // pageBuilder: (context) => const QuestionBankScreen(),
          permissions: ['admin', 'teacher'],
        ),
      ];

  @override
  void onInit() {
    debugPrint('Examination module initialized');
  }

  @override
  void onDispose() {
    debugPrint('Examination module disposed');
  }
}

/// Main Examination Dashboard Widget
class ExaminationDashboardScreen extends ConsumerStatefulWidget {
  const ExaminationDashboardScreen({super.key});

  @override
  ConsumerState<ExaminationDashboardScreen> createState() =>
      _ExaminationDashboardScreenState();
}

class _ExaminationDashboardScreenState
    extends ConsumerState<ExaminationDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    ref.read(examPeriodProvider.notifier).loadExamPeriods();
    ref.read(examScheduleProvider.notifier).loadExamSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final examPeriods = ref.watch(examPeriodProvider);
    final examSchedules = ref.watch(examScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateExamPeriodDialog(context),
            tooltip: 'New Exam Period',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatsCard(examPeriods, examSchedules),
            
            const SizedBox(height: 24),
            
            // Active Exam Period
            _buildActivePeriodSection(examPeriods),
            
            const SizedBox(height: 24),
            
            // Upcoming Exams
            _buildUpcomingExamsSection(examSchedules),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List examPeriods, List examSchedules) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Examination Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Exam Periods',
                  examPeriods.length.toString(),
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  'Scheduled Exams',
                  examSchedules.length.toString(),
                  Icons.event_note,
                ),
                _buildStatItem(
                  'Active Periods',
                  examPeriods.where((p) => p.isActive).length.toString(),
                  Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivePeriodSection(List examPeriods) {
    final activePeriods = examPeriods.where((p) => p.isActive).toList();
    
    if (activePeriods.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No active exam periods'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Exam Periods',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...activePeriods.map((period) => Card(
          child: ListTile(
            title: Text(period.name),
            subtitle: Text(
              '${_formatDate(period.startDate)} - ${_formatDate(period.endDate)}',
            ),
            trailing: Chip(
              label: Text(period.examType.name.toUpperCase()),
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildUpcomingExamsSection(List examSchedules) {
    final now = DateTime.now();
    final upcoming = examSchedules
        .where((s) => s.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Exams',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        upcoming.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No upcoming exams scheduled'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcoming.take(5).length,
                itemBuilder: (context, index) {
                  final exam = upcoming[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: exam.examType == ExamType.written ? Colors.blue : Colors.orange,
                      ),
                      title: Text(exam.subjectName),
                      subtitle: Text(
                        '${_formatDate(exam.date)} | ${_formatTime(exam.startTime)} - ${_formatTime(exam.endTime)}',
                      ),
                      trailing: Text(exam.room ?? ''),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('New Exam Period'),
              onPressed: () => _showCreateExamPeriodDialog(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Exam'),
              onPressed: () => _navigateToScheduleExam(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.grade),
              label: const Text('Enter Results'),
              onPressed: () => _navigateToEnterResults(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Generate Report Cards'),
              onPressed: () => _navigateToReportCards(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateExamPeriodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Exam Period'),
        content: const Text('Exam period creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToScheduleExam(BuildContext context) {
    // Navigation to schedule exam screen
    debugPrint('Navigate to Schedule Exam');
  }

  void _navigateToEnterResults(BuildContext context) {
    // Navigation to enter results screen
    debugPrint('Navigate to Enter Results');
  }

  void _navigateToReportCards(BuildContext context) {
    // Navigation to report cards screen
    debugPrint('Navigate to Report Cards');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
