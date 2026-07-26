import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admission.dart';
import '../providers/admission_providers.dart';

/// Form screen for creating/editing admission application
class AdmissionFormScreen extends ConsumerStatefulWidget {
  final Admission? admission; // null for new, not null for edit

  const AdmissionFormScreen({super.key, this.admission});

  @override
  ConsumerState<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Student Information Controllers
  late TextEditingController _studentNameController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthDateController;
  String _selectedGender = 'L';
  String _selectedReligion = 'Islam';
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  // Parent Information Controllers
  late TextEditingController _fatherNameController;
  late TextEditingController _fatherOccupationController;
  late TextEditingController _fatherPhoneController;
  late TextEditingController _motherNameController;
  late TextEditingController _motherOccupationController;
  late TextEditingController _motherPhoneController;
  
  // Academic Information Controllers
  late TextEditingController _previousSchoolController;
  String _selectedGrade = 'X';
  late TextEditingController _academicYearController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.admission != null) {
      // Edit mode - populate with existing data
      final a = widget.admission!;
      _studentNameController = TextEditingController(text: a.studentName);
      _birthPlaceController = TextEditingController(text: a.birthPlace);
      _birthDateController = TextEditingController(
        text: '${a.birthDate.day}/${a.birthDate.month}/${a.birthDate.year}',
      );
      _selectedGender = a.gender;
      _selectedReligion = a.religion;
      _addressController = TextEditingController(text: a.address);
      _postalCodeController = TextEditingController(text: a.postalCode);
      _phoneController = TextEditingController(text: a.phone);
      _emailController = TextEditingController(text: a.email);
      
      _fatherNameController = TextEditingController(text: a.fatherName);
      _fatherOccupationController = TextEditingController(text: a.fatherOccupation);
      _fatherPhoneController = TextEditingController(text: a.fatherPhone);
      _motherNameController = TextEditingController(text: a.motherName);
      _motherOccupationController = TextEditingController(text: a.motherOccupation);
      _motherPhoneController = TextEditingController(text: a.motherPhone);
      
      _previousSchoolController = TextEditingController(text: a.previousSchool);
      _selectedGrade = a.applyingForGrade;
      _academicYearController = TextEditingController(text: a.academicYear);
    } else {
      // New admission mode
      final currentYear = DateTime.now().year;
      _studentNameController = TextEditingController();
      _birthPlaceController = TextEditingController();
      _birthDateController = TextEditingController();
      _addressController = TextEditingController();
      _postalCodeController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      
      _fatherNameController = TextEditingController();
      _fatherOccupationController = TextEditingController();
      _fatherPhoneController = TextEditingController();
      _motherNameController = TextEditingController();
      _motherOccupationController = TextEditingController();
      _motherPhoneController = TextEditingController();
      
      _previousSchoolController = TextEditingController();
      _academicYearController = TextEditingController(text: '$currentYear/$currentYear+1');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _studentNameController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _fatherNameController.dispose();
    _fatherOccupationController.dispose();
    _fatherPhoneController.dispose();
    _motherNameController.dispose();
    _motherOccupationController.dispose();
    _motherPhoneController.dispose();
    _previousSchoolController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.admission != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Pendaftaran' : 'Pendaftaran Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAdmission,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Informasi Siswa'),
                _buildStudentInfoSection(),
                
                const SizedBox(height: 24),
                _buildSectionHeader('Informasi Orang Tua/Wali'),
                _buildParentInfoSection(),
                
                const SizedBox(height: 24),
                _buildSectionHeader('Informasi Akademik'),
                _buildAcademicInfoSection(),
                
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Batal'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveAdmission,
                          icon: const Icon(Icons.save),
                          label: Text(isEditMode ? 'Update' : 'Daftar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildStudentInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _studentNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama lengkap harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _birthPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Lahir *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                        firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _birthDateController.text = '${date.day}/${date.month}/${date.year}';
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.male),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedReligion,
                    decoration: const InputDecoration(
                      labelText: 'Agama *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.auto_stories),
                    ),
                    items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReligion = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alamat harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Pos *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.markunread_mailbox),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon/HP *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Data Ayah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Ayah *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fatherOccupationController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Ayah *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatherPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telp Ayah *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Data Ibu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motherNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Ibu *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _motherOccupationController,
                    decoration: const InputDecoration(
                      labelText: 'Pekerjaan Ibu *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _motherPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telp Ibu *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _previousSchoolController,
              decoration: const InputDecoration(
                labelText: 'Sekolah Asal *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Mendaftar untuk Kelas *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'VII', 'VIII', 'IX', // SMP
                      'X', 'XI', 'XII',    // SMA
                    ].map((grade) {
                      return DropdownMenuItem(value: grade, child: Text('Kelas $grade'));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _academicYearController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Ajaran *',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: 2024/2025',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan semua data telah diisi dengan benar sebelum mengirim pendaftaran.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
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

  Future<void> _saveAdmission() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse birth date
      final birthDateParts = _birthDateController.text.split('/');
      final birthDate = DateTime(
        int.parse(birthDateParts[2]),
        int.parse(birthDateParts[1]),
        int.parse(birthDateParts[0]),
      );

      final admission = Admission(
        studentName: _studentNameController.text.trim(),
        birthPlace: _birthPlaceController.text.trim(),
        birthDate: birthDate,
        gender: _selectedGender,
        religion: _selectedReligion,
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        fatherOccupation: _fatherOccupationController.text.trim(),
        fatherPhone: _fatherPhoneController.text.trim(),
        motherName: _motherNameController.text.trim(),
        motherOccupation: _motherOccupationController.text.trim(),
        motherPhone: _motherPhoneController.text.trim(),
        previousSchool: _previousSchoolController.text.trim(),
        applyingForGrade: _selectedGrade,
        academicYear: _academicYearController.text.trim(),
        applicationDate: DateTime.now(),
        status: AdmissionStatus.registered,
      );

      if (widget.admission != null) {
        // Update existing
        final updated = admission.copyWith(id: widget.admission!.id);
        final success = await ref.read(admissionNotifierProvider.notifier).updateAdmission(updated);
        
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data pendaftaran berhasil diupdate')),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new
        final result = await ref.read(admissionNotifierProvider.notifier).createAdmission(admission);
        
        if (result != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pendaftaran berhasil! No: ${result.applicationNumber}'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
