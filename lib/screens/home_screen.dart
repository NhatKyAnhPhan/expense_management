import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenseService = context.watch<FirebaseExpenseService>();
    final transactions = expenseService.transactions;
    final budget = expenseService.monthlyBudget;

    // Tính toán tổng thu và tổng chi
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final balance = totalIncome - totalExpense;
    final budgetPercent = budget > 0 ? (totalExpense / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Chi Tiêu', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Đồng bộ Firebase',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dữ liệu được đồng bộ Realtime từ Firebase!')),
              );
            },
          ),
        ],
      ),
      body: expenseService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Tự động đồng bộ với Firebase
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Thẻ Tổng Quan Số Dư (Card Material 3)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số dư hiện tại', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          Text(
                            formatCurrency(balance),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tổng thu (+)', style: TextStyle(color: Colors.green, fontSize: 12)),
                                  Text(formatCurrency(totalIncome), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Tổng chi (-)', style: TextStyle(color: Colors.red, fontSize: 12)),
                                  Text(formatCurrency(totalExpense), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thanh Tiến Trình Ngân Sách Tháng
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ngân sách tháng', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(formatCurrency(budget), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: budgetPercent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: budgetPercent > 0.8 ? Colors.amber : Colors.blue,
                            backgroundColor: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đã sử dụng ${(budgetPercent * 100).toInt()}% ngân sách',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Danh Sách Giao Dịch
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Chưa có giao dịch nào. Bấm nút + để thêm!')),
                    )
                  else
                    ...transactions.map((tx) {
                      final isExpense = tx.type == TransactionType.expense;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                            child: Icon(
                              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(tx.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(tx.note.isNotEmpty ? tx.note : DateFormat('dd/MM/yyyy').format(tx.date)),
                          trailing: Text(
                            '${isExpense ? "-" : "+"}${formatCurrency(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          onLongPress: () {
                            // Xóa giao dịch
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xóa giao dịch?'),
                                content: const Text('Bạn có chắc chắn muốn xóa giao dịch này khỏi Firebase?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                  FilledButton(
                                    onPressed: () {
                                      expenseService.deleteTransaction(tx.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch'),
      ),
    );
  }
}
