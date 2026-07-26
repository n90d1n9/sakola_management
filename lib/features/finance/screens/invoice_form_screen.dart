import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_providers.dart';
import '../models/invoice.dart';
import '../models/fee_structure.dart';
import '../../../core/theme/app_colors.dart';

/// Form screen for creating/editing invoices
class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  late TextEditingController _studentIdController;
  late TextEditingController _studentNameController;
  late TextEditingController _gradeLevelController;
  late TextEditingController _dueDateController;
  late TextEditingController _notesController;
  
  List<InvoiceItem> _items = [];
  FeeCategory _selectedCategory = FeeCategory.tuition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController();
    _studentNameController = TextEditingController();
    _gradeLevelController = TextEditingController();
    _dueDateController = TextEditingController();
    _notesController = TextEditingController();
    
    if (widget.invoice != null) {
      _loadInvoiceData();
    } else {
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30)));
    }
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _studentIdController.text = invoice.studentId.toString();
    _studentNameController.text = invoice.studentName;
    _gradeLevelController.text = invoice.gradeLevel ?? '';
    _dueDateController.text = DateFormat('yyyy-MM-dd').format(invoice.dueDate);
    _notesController.text = invoice.notes ?? '';
    _items = List.from(invoice.items);
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _gradeLevelController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        onAdd: (description, amount) {
          setState(() {
            _items.add(InvoiceItem(description: description, amount: amount));
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu item tagihan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(invoiceNotifierProvider.notifier);
      
      if (widget.invoice != null) {
        // Update existing invoice
        final updatedInvoice = widget.invoice!.copyWith(
          studentName: _studentNameController.text,
          gradeLevel: _gradeLevelController.text,
          dueDate: DateFormat('yyyy-MM-dd').parse(_dueDateController.text),
          items: _items,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        await notifier.updateInvoice(updatedInvoice);
      } else {
        // Create new invoice
        await notifier.createInvoice(
          studentId: int.tryParse(_studentIdController.text) ?? 0,
          studentName: _studentNameController.text,
          gradeLevel: _gradeLevelController.text.isEmpty ? null : _gradeLevelController.text,
          dueDate: DateFormat('yyyy-MM-dd').parse(_dueDateController.text),
          items: _items,
          category: _selectedCategory,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.invoice != null ? 'Invoice berhasil diperbarui' : 'Invoice berhasil dibuat'),
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
        title: Text(widget.invoice != null ? 'Edit Invoice' : 'Buat Invoice Baru'),
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
                    const Text('Informasi Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'NIS',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'NIS wajib diisi';
                        if (int.tryParse(value) == null) return 'NIS harus angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Siswa',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama siswa wajib diisi';
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
                    const Text('Detail Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<FeeCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Biaya',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: FeeCategory.values.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.name.toUpperCase()));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Jatuh Tempo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDueDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Tanggal jatuh tempo wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Item Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: _addItem,
                          tooltip: 'Tambah Item',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Belum ada item. Klik + untuk menambah.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_currencyFormat.format(item.amount)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          _currencyFormat.format(_totalAmount),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
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
                label: Text(widget.invoice != null ? 'Perbarui Invoice' : 'Buat Invoice'),
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

/// Dialog for adding invoice items
class _ItemDialog extends StatefulWidget {
  final Function(String description, double amount) onAdd;

  const _ItemDialog({required this.onAdd});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final amount = double.parse(_amountController.text.replaceAll('.', '').replaceAll(',', '.'));

    widget.onAdd(description, amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Item Tagihan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Deskripsi wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) == null) {
                  return 'Jumlah harus angka';
                }
                return null;
              },
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
          onPressed: _submit,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
