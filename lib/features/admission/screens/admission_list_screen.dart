import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../models/admission.dart';
import '../../providers/admission_providers.dart';
import '../widgets/application_status_badge.dart';

class AdmissionListScreen extends ConsumerStatefulWidget {
  const AdmissionListScreen({super.key});

  @override
  ConsumerState<AdmissionListScreen> createState() => _AdmissionListScreenState();
}

class _AdmissionListScreenState extends ConsumerState<AdmissionListScreen> {
  final _searchController = TextEditingController();
  ApplicationStatus? _selectedStatus;
  String _selectedGrade = '';
  
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final admissionNotifier = ref.watch(admissionNotifierProvider);
    
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: admissionNotifier.when(
            data: (result) {
              if (result.items.isEmpty) {
                return EmptyState(
                  icon: Icons.school_outlined,
                  title: 'Belum ada pendaftar',
                  subtitle: 'Belum ada data pendaftaran untuk kriteria yang dipilih',
                  actionText: 'Tambah Pendaftar',
                  onAction: () => _navigateToForm(),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(admissionNotifierProvider.notifier).getApplications(
                    page: 0,
                    limit: _pageSize,
                    status: _selectedStatus,
                    grade: _selectedGrade,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: result.items.length + (result.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == result.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: LoadingIndicator()),
                      );
                    }

                    final application = result.items[index];
                    return _buildApplicationCard(application);
                  },
                ),
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Cari nama atau nomor pendaftaran...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    // Debounced search
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _navigateToForm,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (_selectedStatus != null || _selectedGrade.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedStatus != null)
                  Chip(
                    label: Text(_selectedStatus!.displayName),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => _selectedStatus = null);
                      _refreshData();
                    },
                  ),
                if (_selectedGrade.isNotEmpty)
                  Chip(
                    label: Text('Kelas: $_selectedGrade'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => _selectedGrade = '');
                      _refreshData();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showApplicationDetail(application),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicationNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.studentName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ApplicationStatusBadge(status: application.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asal Sekolah',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.previousSchool ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Nilai Seleksi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getScoreColor(application.selectionScore).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          application.selectionScore?.toStringAsFixed(1) ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(application.selectionScore),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Daftar: ${DateFormat('dd MMM yyyy', 'id_ID').format(application.submittedAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pendaftaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ApplicationStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Status')),
                ...ApplicationStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGrade.isEmpty ? null : _selectedGrade,
              decoration: const InputDecoration(labelText: 'Kelas Tujuan'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Kelas')),
                ...['10', '7', '1'].map((grade) => DropdownMenuItem(
                  value: grade,
                  child: Text('Kelas $grade'),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedGrade = value ?? '');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedGrade = '';
              });
              Navigator.pop(context);
              _refreshData();
            },
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshData();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetail(Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ApplicationDetailSheet(
          application: application,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _navigateToForm() {
    Navigator.pushNamed(context, '/admission/form');
  }
}

class _ApplicationDetailSheet extends StatelessWidget {
  final Application application;
  final ScrollController scrollController;

  const _ApplicationDetailSheet({
    required this.application,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicationNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      application.studentName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              ApplicationStatusBadge(status: application.status),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('Informasi Pribadi'),
              _buildInfoRow('Nama Lengkap', application.studentName),
              _buildInfoRow('NISN', application.nisn ?? '-'),
              _buildInfoRow('Tempat, Tanggal Lahir', 
                '${application.birthPlace ?? '-'}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(application.birthDate)}'),
              _buildInfoRow('Jenis Kelamin', application.gender == 'L' ? 'Laki-laki' : 'Perempuan'),
              _buildInfoRow('Agama', application.religion ?? '-'),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Kontak'),
              _buildInfoRow('Email', application.email ?? '-'),
              _buildInfoRow('Telepon', application.phone ?? '-'),
              _buildInfoRow('Alamat', application.address ?? '-'),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Informasi Akademik'),
              _buildInfoRow('Asal Sekolah', application.previousSchool ?? '-'),
              _buildInfoRow('Kelas Tujuan', 'Kelas ${application.targetGrade}'),
              _buildInfoRow('Tahun Ajaran', application.academicYear),
              if (application.selectionScore != null) ...[
                _buildInfoRow('Nilai Seleksi', application.selectionScore!.toStringAsFixed(2)),
              ],
              if (application.acceptedClass != null) ...[
                _buildInfoRow('Kelas Diterima', application.acceptedClass),
              ],
              const SizedBox(height: 24),
              
              _buildSectionTitle('Informasi Orang Tua'),
              _buildInfoRow('Nama Ayah', application.parentFatherName ?? '-'),
              _buildInfoRow('Nama Ibu', application.parentMotherName ?? '-'),
              _buildInfoRow('Telepon Orang Tua', application.parentPhone ?? '-'),
              const SizedBox(height: 32),
              
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (application.status) {
      case ApplicationStatus.registered:
        return FilledButton.icon(
          onPressed: () => _verifyApplication(context),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Verifikasi Berkas'),
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        );
      case ApplicationStatus.verified:
        return FilledButton.icon(
          onPressed: () => _enterTestScore(context),
          icon: const Icon(Icons.edit_note),
          label: const Text('Input Nilai Tes'),
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        );
      case ApplicationStatus.tested:
        return FilledButton.icon(
          onPressed: () => _acceptStudent(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Terima Siswa'),
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        );
      case ApplicationStatus.accepted:
        return OutlinedButton.icon(
          onPressed: () => _enrollStudent(context),
          icon: const Icon(Icons.school),
          label: const Text('Daftar Ulang'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _verifyApplication(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka form verifikasi...')),
    );
  }

  void _enterTestScore(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka form input nilai...')),
    );
  }

  void _acceptStudent(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka form penerimaan...')),
    );
  }

  void _enrollStudent(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proses daftar ulang...')),
    );
  }
}
