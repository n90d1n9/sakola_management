import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_providers.dart';
import '../models/invoice.dart';
import '../models/fee_structure.dart';
import '../../../core/theme/app_colors.dart';
import 'invoice_form_screen.dart';
import 'payment_dialog.dart';

/// Enhanced Finance Dashboard with complete CRUD operations
class FinanceDashboardScreen extends ConsumerStatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  ConsumerState<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends ConsumerState<FinanceDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  late TabController _tabController;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoiceNotifierProvider.notifier).loadInvoices();
      ref.read(paymentNotifierProvider.notifier).loadPayments();
      ref.read(feeStructureNotifierProvider.notifier).loadFeeStructures();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await ref.read(invoiceNotifierProvider.notifier).loadInvoices();
    await ref.read(paymentNotifierProvider.notifier).loadPayments();
  }

  void _showCreateInvoiceDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvoiceFormScreen()),
    );
  }

  void _processPayment(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateInvoiceDialog,
            tooltip: 'Buat Invoice Baru',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Invoice'),
            Tab(icon: Icon(Icons.payment), text: 'Pembayaran'),
            Tab(icon: Icon(Icons.list), text: 'Struktur Biaya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoiceTab(),
          _buildPaymentTab(),
          _buildFeeStructureTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInvoiceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Invoice Baru'),
      ),
    );
  }

  Widget _buildInvoiceTab() {
    return Column(
      children: [
        _buildSummaryCards(),
        _buildFilterBar(),
        Expanded(child: _buildInvoiceList()),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Tagihan', 'Rp 0', Icons.account_balance_wallet, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Lunas', 'Rp 0', Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Belum Lunas', 'Rp 0', Icons.pending_actions, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Jatuh Tempo', 'Rp 0', Icons.warning, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari invoice...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _selectedStatus,
            items: ['all', 'pending', 'paid', 'overdue']
                .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    final invoiceState = ref.watch(invoiceNotifierProvider);

    if (invoiceState.isLoading && invoiceState.invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (invoiceState.invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada invoice', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showCreateInvoiceDialog,
              icon: const Icon(Icons.add),
              label: const Text('Buat Invoice Pertama'),
            ),
          ],
        ),
      );
    }

    var invoices = invoiceState.invoices;

    // Apply filters
    if (_selectedStatus != 'all') {
      invoices = invoices.where((i) => i.status.name == _selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      invoices = invoices
          .where((i) =>
              i.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.studentName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(invoice.status).withOpacity(0.2),
              child: Icon(Icons.receipt, color: _getStatusColor(invoice.status)),
            ),
            title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.studentName),
                Text(_currencyFormat.format(invoice.totalAmount)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(
                    invoice.status.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(invoice.status),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(invoice.dueDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () => _showInvoiceDetail(invoice),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTab() {
    final paymentState = ref.watch(paymentNotifierProvider);

    if (paymentState.isLoading && paymentState.payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentState.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada pembayaran', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentState.payments.length,
      itemBuilder: (context, index) {
        final payment = paymentState.payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            title: Text(payment.invoiceNumber),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.paymentMethod.name),
                Text(_currencyFormat.format(payment.amount)),
                Text('Terima kasih, ${payment.paidBy}'),
              ],
            ),
            trailing: Text(
              DateFormat('dd MMM yyyy').format(payment.paymentDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeStructureTab() {
    final feeState = ref.watch(feeStructureNotifierProvider);

    if (feeState.isLoading && feeState.feeStructures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feeState.feeStructures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada struktur biaya', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feeState.feeStructures.length,
      itemBuilder: (context, index) {
        final fee = feeState.feeStructures[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(Icons.attach_money, color: Colors.blue),
            ),
            title: Text(fee.name),
            subtitle: Text('${fee.category.name} - ${fee.frequency?.name ?? "Sekali"}'),
            trailing: Text(
              _currencyFormat.format(fee.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.pending:
        return Colors.orange;
    }
  }

  void _showInvoiceDetail(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                      invoice.invoiceNumber,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(
                        invoice.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(invoice.status),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDetailRow('Siswa', invoice.studentName),
                _buildDetailRow('NIS', invoice.studentId.toString()),
                _buildDetailRow('Kelas', invoice.gradeLevel ?? '-'),
                _buildDetailRow(
                  'Tanggal Jatuh Tempo',
                  DateFormat('dd MMMM yyyy').format(invoice.dueDate),
                ),
                const SizedBox(height: 16),
                const Text('Item Tagihan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.description),
                          Text(_currencyFormat.format(item.amount)),
                        ],
                      ),
                    )),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      _currencyFormat.format(invoice.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (invoice.status != InvoiceStatus.paid)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _processPayment(invoice);
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Proses Pembayaran'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
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
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
