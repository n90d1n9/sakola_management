import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_providers.dart';
import '../models/invoice.dart';
import '../models/fee_structure.dart';
import '../../../core/theme/app_colors.dart';

/// Dashboard screen for Finance module
class FinanceDashboardScreen extends ConsumerStatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  ConsumerState<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends ConsumerState<FinanceDashboardScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invoiceNotifierProvider.notifier).loadInvoices();
      ref.read(paymentNotifierProvider.notifier).loadPayments();
    });
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
            onPressed: () => _showCreateInvoiceDialog(),
            tooltip: 'Buat Invoice Baru',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Summary Cards
              _buildRevenueSummary(),
              
              const SizedBox(height: 24),
              
              // Quick Stats
              _buildQuickStats(),
              
              const SizedBox(height: 24),
              
              // Recent Invoices
              _buildRecentInvoices(),
              
              const SizedBox(height: 24),
              
              // Payment Methods Chart Placeholder
              _buildPaymentMethodsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordPaymentDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.payment),
        label: const Text('Catat Pembayaran'),
      ),
    );
  }

  /// Build Revenue Summary Section
  Widget _buildRevenueSummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(financeStatisticsProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Gagal memuat data keuangan'),
            ),
          );
        }

        final stats = snapshot.data!;
        final totalRevenue = stats['totalRevenue'] as double;
        final expectedRevenue = stats['expectedRevenue'] as double;
        final collectionRate = stats['collectionRate'] as double;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pendapatan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Terkumpul',
                    _currencyFormat.format(totalRevenue),
                    Icons.account_balance_wallet,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Target',
                    _currencyFormat.format(expectedRevenue),
                    Icons.target,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tingkat Koleksi',
                    '${collectionRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    collectionRate >= 80 ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sisa Tagihan',
                    _currencyFormat.format(expectedRevenue - totalRevenue),
                    Icons.money_off,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Quick Stats Section
  Widget _buildQuickStats() {
    final invoiceState = ref.watch(invoiceNotifierProvider);
    
    final totalInvoices = invoiceState.length;
    final paidCount = invoiceState.where((i) => i.status == InvoiceStatus.paid).length;
    final pendingCount = invoiceState.where((i) => i.status == InvoiceStatus.pending).length;
    final overdueCount = ref.read(invoiceNotifierProvider.notifier).getOverdueInvoices().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Invoice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStatItem('Total', totalInvoices.toString(), AppColors.primary),
                _buildQuickStatItem('Lunas', paidCount.toString(), AppColors.success),
                _buildQuickStatItem('Pending', pendingCount.toString(), AppColors.warning),
                _buildQuickStatItem('Terlambat', overdueCount.toString(), AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// Build Recent Invoices Section
  Widget _buildRecentInvoices() {
    final invoiceState = ref.watch(invoiceNotifierProvider);
    final recentInvoices = invoiceState.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full invoice list
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentInvoices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada invoice'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentInvoices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final invoice = recentInvoices[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(invoice.status).withOpacity(0.1),
                      child: Icon(
                        Icons.receipt_long,
                        color: _getStatusColor(invoice.status),
                      ),
                    ),
                    title: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Student: ${invoice.studentId}\nJatuh Tempo: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(invoice.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(invoice.status),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(invoice.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showInvoiceDetails(invoice),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Build Payment Methods Section
  Widget _buildPaymentMethodsSection() {
    final paymentState = ref.watch(paymentNotifierProvider);
    final stats = ref.read(paymentNotifierProvider.notifier).getPaymentStatistics();
    final byMethod = stats['byMethod'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (byMethod.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada data pembayaran'),
                ),
              )
            else
              ...byMethod.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(_getMethodLabel(entry.key)),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: (entry.value as double) / (stats['totalAmount'] as double),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currencyFormat.format(entry.value),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.pending:
        return AppColors.warning;
      case InvoiceStatus.partiallyPaid:
        return AppColors.info;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Lunas';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.partiallyPaid:
        return 'Sebagian';
      case InvoiceStatus.overdue:
        return 'Terlambat';
      case InvoiceStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'qris':
        return 'QRIS';
      case 'virtual_account':
        return 'Virtual Account';
      case 'e_wallet':
        return 'E-Wallet';
      case 'cash':
        return 'Tunai';
      default:
        return method;
    }
  }

  Future<void> _refreshData() async {
    await ref.read(invoiceNotifierProvider.notifier).loadInvoices();
    await ref.read(paymentNotifierProvider.notifier).loadPayments();
  }

  void _showCreateInvoiceDialog() {
    // TODO: Implement create invoice dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Invoice Baru'),
        content: const Text('Form pembuatan invoice akan ditampilkan di sini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentDialog() {
    // TODO: Implement record payment dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Pembayaran'),
        content: const Text('Form pencatatan pembayaran akan ditampilkan di sini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    // TODO: Implement invoice details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Invoice ${invoice.invoiceNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Student ID', invoice.studentId),
              _buildDetailRow('Total', _currencyFormat.format(invoice.totalAmount)),
              _buildDetailRow('Terbayar', _currencyFormat.format(invoice.totalPaid)),
              _buildDetailRow('Sisa', _currencyFormat.format(invoice.balance)),
              _buildDetailRow('Jatuh Tempo', DateFormat('dd MMM yyyy').format(invoice.dueDate)),
              _buildDetailRow('Status', _getStatusText(invoice.status)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
