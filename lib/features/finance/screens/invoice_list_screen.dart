import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/pagination_result.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../models/invoice.dart';
import '../../providers/finance_providers.dart';
import '../widgets/payment_status_badge.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _searchController = TextEditingController();
  InvoiceStatus? _selectedStatus;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  
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
    final invoiceNotifier = ref.watch(invoiceNotifierProvider);
    
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: invoiceNotifier.when(
            data: (result) {
              if (result.items.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada invoice',
                  subtitle: 'Belum ada data invoice untuk kriteria yang dipilih',
                  actionText: 'Buat Invoice Baru',
                  onAction: () => _navigateToForm(),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(invoiceNotifierProvider.notifier).getInvoices(
                    page: 0,
                    limit: _pageSize,
                    status: _selectedStatus,
                    month: _selectedMonth,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: result.items.length + (result.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == result.items.length) {
                      // Load more indicator
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: LoadingIndicator()),
                      );
                    }

                    final invoice = result.items[index];
                    return _buildInvoiceCard(invoice);
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
                  hintText: 'Cari nomor invoice atau siswa...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    // Debounced search implementation
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
          if (_selectedStatus != null || _selectedMonth.isNotEmpty) ...[
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
                Chip(
                  label: Text('Bulan: ${_selectedMonth}'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _selectedMonth = '');
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

  Widget _buildInvoiceCard(Invoice invoice) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showInvoiceDetail(invoice),
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
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.studentName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PaymentStatusBadge(status: invoice.status),
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
                        'Jatuh Tempo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy', 'id_ID').format(invoice.dueDate),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(invoice.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (invoice.status == InvoiceStatus.overdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Terlambat ${invoice.daysOverdue} hari',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<InvoiceStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Status')),
                ...InvoiceStatus.values.map((status) => DropdownMenuItem(
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
              value: _selectedMonth.isEmpty ? null : _selectedMonth,
              decoration: const InputDecoration(labelText: 'Bulan'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Bulan')),
                ...List.generate(12, (index) {
                  final date = DateTime.now().subtract(Duration(days: 30 * index));
                  final month = DateFormat('yyyy-MM').format(date);
                  final display = DateFormat('MMMM yyyy', 'id_ID').format(date);
                  return DropdownMenuItem(value: month, child: Text(display));
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedMonth = value ?? '');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedMonth = '';
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

  void _showInvoiceDetail(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _InvoiceDetailSheet(
          invoice: invoice,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _navigateToForm() {
    Navigator.pushNamed(context, '/finance/invoice-form');
  }
}

class _InvoiceDetailSheet extends StatelessWidget {
  final Invoice invoice;
  final ScrollController scrollController;

  const _InvoiceDetailSheet({
    required this.invoice,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                child: const Icon(Icons.receipt_long, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      invoice.studentName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              PaymentStatusBadge(status: invoice.status),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              _buildInfoRow('Tanggal Invoice', DateFormat('dd MMMM yyyy', 'id_ID').format(invoice.issueDate)),
              _buildInfoRow('Jatuh Tempo', DateFormat('dd MMMM yyyy', 'id_ID').format(invoice.dueDate)),
              _buildInfoRow('Keterangan', invoice.description ?? '-'),
              const SizedBox(height: 24),
              const Text(
                'Item Invoice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...invoice.items.map((item) => Card(
                child: ListTile(
                  title: Text(item.description),
                  subtitle: Text('${item.quantity} x ${currencyFormat.format(item.unitPrice)}'),
                  trailing: Text(
                    currencyFormat.format(item.quantity * item.unitPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    currencyFormat.format(invoice.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              if (invoice.paidAmount > 0) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sudah Dibayar',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    Text(
                      currencyFormat.format(invoice.paidAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sisa',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                    Text(
                      currencyFormat.format(invoice.remainingAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              if (invoice.status != InvoiceStatus.paid)
                FilledButton.icon(
                  onPressed: () => _processPayment(context),
                  icon: const Icon(Icons.payment),
                  label: const Text('Bayar Sekarang'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              if (invoice.status == InvoiceStatus.paid)
                OutlinedButton.icon(
                  onPressed: () => _downloadReceipt(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Unduh Kwitansi'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  void _processPayment(BuildContext context) {
    Navigator.pop(context);
    // Navigate to payment dialog or screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proses Pembayaran'),
        content: Text('Pembayaran untuk invoice ${invoice.invoiceNumber}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              // Implement payment logic
              Navigator.pop(context);
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh kwitansi...')),
    );
  }
}
