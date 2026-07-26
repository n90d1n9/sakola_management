import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/features/features_base.dart';
import '../models/admission.dart';
import '../providers/admission_providers.dart';

/// Admission Feature Module Registration
class AdmissionFeature extends FeatureModule {
  @override
  String get name => 'Admission';

  @override
  String get description => 'Manage student admission (PPDB), applications, and enrollment';

  @override
  IconData get icon => Icons.how_to_reg;

  @override
  List<FeatureRoute> get routes => [
        FeatureRoute(
          path: '/admission',
          name: 'Admission Dashboard',
          // pageBuilder: (context) => const AdmissionDashboardScreen(),
          permissions: ['admin', 'admission_staff'],
        ),
        FeatureRoute(
          path: '/admission/applications',
          name: 'Applications',
          // pageBuilder: (context) => const ApplicationListScreen(),
          permissions: ['admin', 'admission_staff'],
        ),
        FeatureRoute(
          path: '/admission/verification',
          name: 'Document Verification',
          // pageBuilder: (context) => const VerificationScreen(),
          permissions: ['admin', 'admission_staff'],
        ),
        FeatureRoute(
          path: '/admission/examination',
          name: 'Selection Examination',
          // pageBuilder: (context) => const SelectionExamScreen(),
          permissions: ['admin', 'admission_staff'],
        ),
        FeatureRoute(
          path: '/admission/enrollment',
          name: 'Enrollment',
          // pageBuilder: (context) => const EnrollmentScreen(),
          permissions: ['admin', 'admission_staff'],
        ),
      ];

  @override
  void onInit() {
    debugPrint('Admission module initialized');
  }

  @override
  void onDispose() {
    debugPrint('Admission module disposed');
  }
}

/// Main Admission Dashboard Widget
class AdmissionDashboardScreen extends ConsumerStatefulWidget {
  const AdmissionDashboardScreen({super.key});

  @override
  ConsumerState<AdmissionDashboardScreen> createState() =>
      _AdmissionDashboardScreenState();
}

class _AdmissionDashboardScreenState
    extends ConsumerState<AdmissionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(admissionNotifierProvider.notifier).loadAdmissions();
  }

  @override
  Widget build(BuildContext context) {
    final admissions = ref.watch(admissionNotifierProvider);
    final statsFuture = ref.watch(admissionStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard PPDB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(admissionNotifierProvider.notifier).loadAdmissions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(admissionNotifierProvider.notifier).loadAdmissions();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              statsFuture.when(
                data: (stats) => _buildQuickStats(stats),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 24),
              
              // Recent Applications
              const Text(
                'Pendaftaran Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (admissions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pendaftaran',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: admissions.length > 5 ? 5 : admissions.length,
                  itemBuilder: (context, index) {
                    final admission = admissions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(admission.status),
                          child: Text(
                            admission.studentName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(admission.studentName),
                        subtitle: Text(
                          '${admission.applicationNumber} • Kelas ${admission.applyingForGrade}',
                        ),
                        trailing: _buildStatusChip(admission.status),
                        onTap: () {
                          // Navigate to detail
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/admission/form');
        },
        icon: const Icon(Icons.add),
        label: const Text('Pendaftaran Baru'),
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Pendaftar',
          stats['totalApplications'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Diterima',
          stats['acceptedCount'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Daftar Ulang',
          stats['enrolledCount'].toString(),
          Icons.how_to_reg,
          Colors.teal,
        ),
        _buildStatCard(
          'Proses Verifikasi',
          stats['verifiedCount'].toString(),
          Icons.verified_user,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AdmissionStatus status) {
    Color color;
    switch (status) {
      case AdmissionStatus.registered:
        color = Colors.blue;
        break;
      case AdmissionStatus.verified:
        color = Colors.orange;
        break;
      case AdmissionStatus.tested:
        color = Colors.purple;
        break;
      case AdmissionStatus.accepted:
        color = Colors.green;
        break;
      case AdmissionStatus.rejected:
        color = Colors.red;
        break;
      case AdmissionStatus.waitlisted:
        color = Colors.amber;
        break;
      case AdmissionStatus.enrolled:
        color = Colors.teal;
        break;
    }

    return Chip(
      label: Text(status.label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getStatusColor(AdmissionStatus status) {
    switch (status) {
      case AdmissionStatus.registered:
        return Colors.blue;
      case AdmissionStatus.verified:
        return Colors.orange;
      case AdmissionStatus.tested:
        return Colors.purple;
      case AdmissionStatus.accepted:
        return Colors.green;
      case AdmissionStatus.rejected:
        return Colors.red;
      case AdmissionStatus.waitlisted:
        return Colors.amber;
      case AdmissionStatus.enrolled:
        return Colors.teal;
    }
  }
}
