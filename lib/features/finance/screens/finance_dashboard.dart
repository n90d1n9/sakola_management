import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/features/features_base.dart';
import '../models/fee_structure.dart';
import '../models/invoice.dart';
import '../states/finance_providers.dart';

/// Finance Feature Module Registration
class FinanceFeature extends FeatureModule {
  @override
  String get name => 'Finance';

  @override
  String get description => 'Manage school fees, invoices, payments, and financial reports';

  @override
  IconData get icon => Icons.attach_money;

  @override
  List<FeatureRoute> get routes => [
        FeatureRoute(
          path: '/finance',
          name: 'Finance Dashboard',
          // pageBuilder: (context) => const FinanceDashboardScreen(),
          permissions: ['admin', 'finance_staff'],
        ),
        FeatureRoute(
          path: '/finance/fee-structures',
          name: 'Fee Structures',
          // pageBuilder: (context) => const FeeStructureListScreen(),
          permissions: ['admin', 'finance_staff'],
        ),
        FeatureRoute(
          path: '/finance/invoices',
          name: 'Invoices',
          // pageBuilder: (context) => const InvoiceListScreen(),
          permissions: ['admin', 'finance_staff', 'teacher'],
        ),
        FeatureRoute(
          path: '/finance/payments',
          name: 'Payments',
          // pageBuilder: (context) => const PaymentListScreen(),
          permissions: ['admin', 'finance_staff'],
        ),
        FeatureRoute(
          path: '/finance/reports',
          name: 'Financial Reports',
          // pageBuilder: (context) => const FinancialReportsScreen(),
          permissions: ['admin', 'finance_staff'],
        ),
      ];

  @override
  void onInit() {
    debugPrint('Finance module initialized');
  }

  @override
  void onDispose() {
    debugPrint('Finance module disposed');
  }
}

/// Main Finance Dashboard Widget
class FinanceDashboardScreen extends ConsumerStatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  ConsumerState<FinanceDashboardScreen> createState() =>
      _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends ConsumerState<FinanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(feeStructureProvider.notifier).loadFeeStructures();
    ref.read(invoiceProvider.notifier).loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    final feeStructures = ref.watch(feeStructureProvider);
    final invoices = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateInvoiceDialog(context),
            tooltip: 'New Invoice',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Summary
            _buildFinancialSummary(invoices),
            
            const SizedBox(height: 24),
            
            // Revenue Breakdown
            _buildRevenueBreakdown(invoices),
            
            const SizedBox(height: 24),
            
            // Recent Invoices
            _buildRecentInvoices(invoices),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(List invoices) {
    final totalRevenue = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold<double>(0, (sum, i) => sum + i.totalAmount);
    
    final pendingRevenue = invoices
        .where((i) => i.status == InvoiceStatus.pending)
        .fold<double>(0, (sum, i) => sum + i.totalAmount);
    
    final overdueCount = invoices.where((i) => i.isOverdue).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Revenue',
                  _formatCurrency(totalRevenue),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                _buildStatItem(
                  'Pending',
                  _formatCurrency(pendingRevenue),
                  Icons.schedule,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Overdue',
                  '$overdueCount',
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdown(List invoices) {
    // Group by fee type
    final byType = <String, double>{};
    for (var invoice in invoices) {
      if (invoice.status == InvoiceStatus.paid) {
        final type = invoice.feeType.name.toUpperCase();
        byType[type] = (byType[type] ?? 0) + invoice.totalAmount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue by Fee Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            byType.isEmpty
                ? const Text('No revenue data available')
                : Column(
                    children: byType.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(
                              _formatCurrency(entry.value),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoices(List invoices) {
    final recent = invoices
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Invoices',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.take(5).length,
          itemBuilder: (context, index) {
            final invoice = recent[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(invoice.status),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text('INV-${invoice.id.substring(0, 8)}'),
                subtitle: Text(
                  '${invoice.studentName} • ${invoice.feeType.name.toUpperCase()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(invoice.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(invoice.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: invoice.isOverdue ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('New Invoice'),
              onPressed: () => _showCreateInvoiceDialog(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
              onPressed: () => _navigateToRecordPayment(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt),
              label: const Text('View Reports'),
              onPressed: () => _navigateToReports(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Fee Settings'),
              onPressed: () => _navigateToFeeSettings(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Invoice'),
        content: const Text('Invoice creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToRecordPayment(BuildContext context) {
    debugPrint('Navigate to Record Payment');
  }

  void _navigateToReports(BuildContext context) {
    debugPrint('Navigate to Reports');
  }

  void _navigateToFeeSettings(BuildContext context) {
    debugPrint('Navigate to Fee Settings');
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    // Indonesian Rupiah format
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
