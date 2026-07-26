import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/admission_providers.dart';
import '../models/admission.dart';

/// Main Admission/PPDB Dashboard Screen
class AdmissionMainScreen extends ConsumerStatefulWidget {
  const AdmissionMainScreen({super.key});

  @override
  ConsumerState<AdmissionMainScreen> createState() => _AdmissionMainScreenState();
}

class _AdmissionMainScreenState extends ConsumerState<AdmissionMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAcademicYear;
  AdmissionStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadAdmissions() {
    ref.read(admissionNotifierProvider.notifier).loadAdmissions(
      academicYear: _selectedAcademicYear,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPDB / Penerimaan Siswa Baru'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Daftar'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Baru'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistik'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdmissions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau nomor pendaftaran...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      if (value.length >= 2) {
                        ref.read(admissionNotifierProvider.notifier).searchAdmissions(value);
                      } else if (value.isEmpty) {
                        _loadAdmissions();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Tahun Ajaran'),
                  value: _selectedAcademicYear,
                  items: ['2024', '2025', '2026'].map((year) {
                    return DropdownMenuItem(value: year, child: Text(year));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAcademicYear = value;
                      _loadAdmissions();
                    });
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<AdmissionStatus>(
                  onSelected: (status) {
                    setState(() {
                      _selectedStatus = status == _selectedStatus ? null : status;
                      _loadAdmissions();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('Semua Status')),
                    ...AdmissionStatus.values.map((status) {
                      return PopupMenuItem(value: status, child: Text(status.label));
                    }),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list),
                        const SizedBox(width: 4),
                        Text(_selectedStatus?.label ?? 'Filter'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAdmissionListTab(),
                _buildNewApplicationTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddApplicationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Pendaftaran Baru'),
            )
          : null,
    );
  }

  Widget _buildAdmissionListTab() {
    final admissionsAsync = ref.watch(admissionNotifierProvider);
    
    if (admissionsAsync.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data pendaftaran',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddApplicationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pendaftaran Baru'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAdmissions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admissionsAsync.length,
        itemBuilder: (context, index) {
          final admission = admissionsAsync[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(admission.status),
                child: Text(
                  admission.studentName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                admission.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('No: ${admission.applicationNumber}'),
                  Text('Grade: ${admission.applyingForGrade} • ${admission.previousSchool}'),
                  const SizedBox(height: 4),
                  _buildStatusChip(admission.status),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAdmissionDetail(admission),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewApplicationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          const Text(
            'Persyaratan Pendaftaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem('Fotokopi Akta Kelahiran (2 lembar)'),
          _buildRequirementItem('Fotokopi Kartu Keluarga (2 lembar)'),
          _buildRequirementItem('Fotokopi KTP Orang Tua (2 lembar)'),
          _buildRequirementItem('Pas Foto 3x4 (4 lembar)'),
          _buildRequirementItem('Surat Keterangan Lulus dari sekolah asal'),
          _buildRequirementItem('Raport semester 1-5 untuk SMP/SMA'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddApplicationDialog(),
            icon: const Icon(Icons.edit_document),
            label: const Text('Mulai Pendaftaran Online'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final statsFuture = ref.watch(admissionStatisticsProvider);
    
    return statsFuture.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard('Total Pendaftar', stats['totalApplications'].toString(), Icons.people),
              const SizedBox(height: 16),
              _buildStatCard('Diterima', stats['acceptedCount'].toString(), Icons.check_circle, color: Colors.green),
              const SizedBox(height: 16),
              _buildStatCard('Daftar Ulang', stats['enrolledCount'].toString(), Icons.how_to_reg, color: Colors.blue),
              const SizedBox(height: 16),
              _buildStatCard('Tingkat Penerimaan', '${stats['acceptanceRate'].toStringAsFixed(1)}%', Icons.trending_up, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Status Pendaftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildStatusStats(stats['byStatus'] as Map<String, dynamic>),
              const SizedBox(height: 24),
              const Text(
                'Pendaftar per Jenjang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildGradeStats(stats['byGrade'] as Map<String, dynamic>),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusStats(Map<String, dynamic> byStatus) {
    return byStatus.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entry.key),
            Chip(
              label: Text('${entry.value}'),
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildGradeStats(Map<String, dynamic> byGrade) {
    return byGrade.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kelas ${entry.key}'),
            Chip(
              label: Text('${entry.value}'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildInfoCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi PPDB',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pendaftaran Tahun Ajaran 2024/2025 telah dibuka.\nSilakan lengkapi persyaratan dan isi formulir online.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
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
      label: Text(status.label, style: const TextStyle(fontSize: 12, color: Colors.white)),
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

  void _showAddApplicationDialog() {
    Navigator.pushNamed(context, '/admission/form');
  }

  void _showAdmissionDetail(Admission admission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  admission.studentName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  admission.applicationNumber,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Divider(height: 32),
                _buildDetailRow('Tempat/Tgl Lahir', '${admission.birthPlace}, ${DateFormat('dd MMMM yyyy').format(admission.birthDate)}'),
                _buildDetailRow('Jenis Kelamin', admission.gender == 'L' ? 'Laki-laki' : 'Perempuan'),
                _buildDetailRow('Agama', admission.religion),
                _buildDetailRow('Alamat', admission.address),
                _buildDetailRow('No. Telepon', admission.phone),
                _buildDetailRow('Email', admission.email),
                const Divider(height: 32),
                _buildDetailRow('Nama Ayah', admission.fatherName),
                _buildDetailRow('Pekerjaan Ayah', admission.fatherOccupation),
                _buildDetailRow('No. Telp Ayah', admission.fatherPhone),
                _buildDetailRow('Nama Ibu', admission.motherName),
                _buildDetailRow('Pekerjaan Ibu', admission.motherOccupation),
                _buildDetailRow('No. Telp Ibu', admission.motherPhone),
                const Divider(height: 32),
                _buildDetailRow('Sekolah Asal', admission.previousSchool),
                _buildDetailRow('Mendaftar untuk', 'Kelas ${admission.applyingForGrade}'),
                _buildDetailRow('Tahun Ajaran', admission.academicYear),
                const Divider(height: 32),
                _buildDetailRow('Status', admission.status.label),
                if (admission.selectionScore != null)
                  _buildDetailRow('Nilai Seleksi', admission.selectionScore.toString()),
                if (admission.assignedClass != null)
                  _buildDetailRow('Kelas Ditugaskan', admission.assignedClass),
                if (admission.notes != null)
                  _buildDetailRow('Catatan', admission.notes!),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Edit action
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showStatusUpdateDialog(admission);
                        },
                        icon: const Icon(Icons.update),
                        label: const Text('Update Status'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
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

  void _showStatusUpdateDialog(Admission admission) {
    AdmissionStatus? selectedStatus = admission.status;
    final scoreController = TextEditingController(text: admission.selectionScore?.toString() ?? '');
    final classController = TextEditingController(text: admission.assignedClass ?? '');
    final notesController = TextEditingController(text: admission.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Status Pendaftaran'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AdmissionStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: AdmissionStatus.values.map((status) {
                      return DropdownMenuItem(value: status, child: Text(status.label));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: scoreController,
                    decoration: const InputDecoration(
                      labelText: 'Nilai Seleksi',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: classController,
                    decoration: const InputDecoration(
                      labelText: 'Kelas Ditugaskan',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: X-A, VII-1',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final score = double.tryParse(scoreController.text);
                  await ref.read(admissionNotifierProvider.notifier).updateAdmissionStatus(
                    admission.id!,
                    selectedStatus!,
                    selectionScore: score,
                    assignedClass: classController.text.isEmpty ? null : classController.text,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status berhasil diupdate')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
