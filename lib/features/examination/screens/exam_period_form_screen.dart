import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../states/exam_providers.dart';
import '../models/exam_period.dart';
import '../../../core/theme/app_colors.dart';

/// Form screen for creating/editing exam periods
class ExamPeriodFormScreen extends ConsumerStatefulWidget {
  final ExamPeriod? period;

  const ExamPeriodFormScreen({super.key, this.period});

  @override
  ConsumerState<ExamPeriodFormScreen> createState() => _ExamPeriodFormScreenState();
}

class _ExamPeriodFormScreenState extends ConsumerState<ExamPeriodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _descriptionController;
  late TextEditingController _academicYearController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  
  ExamType _selectedExamType = ExamType.uts;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _academicYearController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    
    if (widget.period != null) {
      _loadPeriodData();
    } else {
      // Default to current academic year
      final now = DateTime.now();
      _academicYearController.text = '${now.year}/${now.year + 1}';
      _startDateController.text = DateFormat('yyyy-MM-dd').format(now);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 14)));
    }
  }

  void _loadPeriodData() {
    final period = widget.period!;
    _descriptionController.text = period.description;
    _academicYearController.text = period.academicYear;
    _startDateController.text = DateFormat('yyyy-MM-dd').format(period.startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(period.endDate);
    _selectedExamType = period.examType;
    _isActive = period.isActive;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _academicYearController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    final endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal akhir tidak boleh sebelum tanggal mulai')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(examPeriodNotifierProvider.notifier);
      
      if (widget.period != null) {
        // Update existing period
        final updatedPeriod = widget.period!.copyWith(
          description: _descriptionController.text,
          academicYear: _academicYearController.text,
          startDate: startDate,
          endDate: endDate,
          examType: _selectedExamType,
          isActive: _isActive,
        );
        await notifier.updateExamPeriod(updatedPeriod);
      } else {
        // Create new period
        final newPeriod = ExamPeriod(
          description: _descriptionController.text,
          academicYear: _academicYearController.text,
          startDate: startDate,
          endDate: endDate,
          examType: _selectedExamType,
          isActive: _isActive,
        );
        await notifier.addExamPeriod(newPeriod);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.period != null ? 'Periode berhasil diperbarui' : 'Periode berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.period != null ? 'Edit Periode Ujian' : 'Buat Periode Ujian Baru'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Periode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ExamType>(
                      value: _selectedExamType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Ujian',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ExamType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedExamType = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Deskripsi wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _academicYearController,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Akademik',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: '2024/2025',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tahun akademik wajib diisi';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tanggal Periode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_available),
                      ),
                      readOnly: true,
                      onTap: _selectStartDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal mulai wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Akhir',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_busy),
                      ),
                      readOnly: true,
                      onTap: _selectEndDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal akhir wajib diisi';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SwitchListTile(
                  title: const Text('Periode Aktif'),
                  subtitle: const Text('Aktifkan periode ini untuk penjadwalan ujian'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: const Icon(Icons.save),
                label: Text(widget.period != null ? 'Perbarui Periode' : 'Buat Periode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
