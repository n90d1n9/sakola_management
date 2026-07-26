import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../states/exam_providers.dart';
import '../models/exam_schedule.dart';
import '../../../core/theme/app_colors.dart';

/// Form screen for creating/editing exam schedules
class ExamScheduleFormScreen extends ConsumerStatefulWidget {
  final ExamSchedule? schedule;

  const ExamScheduleFormScreen({super.key, this.schedule});

  @override
  ConsumerState<ExamScheduleFormScreen> createState() => _ExamScheduleFormScreenState();
}

class _ExamScheduleFormScreenState extends ConsumerState<ExamScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _subjectController;
  late TextEditingController _gradeLevelController;
  late TextEditingController _teacherNameController;
  late TextEditingController _roomController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _examPeriodIdController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _gradeLevelController = TextEditingController();
    _teacherNameController = TextEditingController();
    _roomController = TextEditingController();
    _dateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _examPeriodIdController = TextEditingController();
    
    if (widget.schedule != null) {
      _loadScheduleData();
    } else {
      final now = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 7)));
      _startTimeController.text = '08:00';
      _endTimeController.text = '10:00';
    }
  }

  void _loadScheduleData() {
    final schedule = widget.schedule!;
    _subjectController.text = schedule.subject;
    _gradeLevelController.text = schedule.gradeLevel;
    _teacherNameController.text = schedule.teacherName;
    _roomController.text = schedule.room;
    _dateController.text = DateFormat('yyyy-MM-dd').format(schedule.date);
    _startTimeController.text = schedule.startTime;
    _endTimeController.text = schedule.endTime;
    _examPeriodIdController.text = schedule.examPeriodId.toString();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeLevelController.dispose();
    _teacherNameController.dispose();
    _roomController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _examPeriodIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTimeController.text = time.format(context);
        } else {
          _endTimeController.text = time.format(context);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(examScheduleNotifierProvider.notifier);
      
      if (widget.schedule != null) {
        // Update existing schedule
        final updatedSchedule = widget.schedule!.copyWith(
          subject: _subjectController.text,
          gradeLevel: _gradeLevelController.text,
          teacherName: _teacherNameController.text,
          room: _roomController.text,
          date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          examPeriodId: int.tryParse(_examPeriodIdController.text) ?? 0,
        );
        await notifier.updateExamSchedule(updatedSchedule);
      } else {
        // Create new schedule
        final newSchedule = ExamSchedule(
          subject: _subjectController.text,
          gradeLevel: _gradeLevelController.text,
          teacherName: _teacherNameController.text,
          room: _roomController.text,
          date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          examPeriodId: int.tryParse(_examPeriodIdController.text) ?? 0,
        );
        await notifier.addExamSchedule(newSchedule);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.schedule != null ? 'Jadwal berhasil diperbarui' : 'Jadwal berhasil dibuat'),
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
        title: Text(widget.schedule != null ? 'Edit Jadwal Ujian' : 'Buat Jadwal Ujian Baru'),
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
                    const Text('Informasi Ujian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Mata Pelajaran',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Mata pelajaran wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _gradeLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                        hintText: 'Contoh: X IPA 1',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kelas wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _teacherNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Guru Pengawas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama guru wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        labelText: 'Ruang Ujian',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                        hintText: 'Opsional',
                      ),
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
                    const Text('Waktu & Tanggal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Ujian',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Jam Mulai',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Jam mulai wajib diisi';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Jam Selesai',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(false),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Jam selesai wajib diisi';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _examPeriodIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Periode Ujian',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event_note),
                    hintText: 'Masukkan ID periode ujian',
                  ),
                  keyboardType: TextInputType.number,
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
                label: Text(widget.schedule != null ? 'Perbarui Jadwal' : 'Buat Jadwal'),
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
