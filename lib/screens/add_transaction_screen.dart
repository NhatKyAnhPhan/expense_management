import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'food';
  String _selectedCategoryName = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _categories = [
    {'id': 'food', 'name': 'Ăn uống'},
    {'id': 'transport', 'name': 'Đi lại'},
    {'id': 'shopping', 'name': 'Mua sắm'},
    {'id': 'bills', 'name': 'Hóa đơn & Tiện ích'},
    {'id': 'entertainment', 'name': 'Giải trí'},
    {'id': 'salary', 'name': 'Lương chính'},
    {'id': 'freelance', 'name': 'Việc ngoài'},
    {'id': 'other', 'name': 'Khác'},
  ];

  void _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final service = context.read<FirebaseExpenseService>();
    final newTx = TransactionModel(
      id: '',
      userId: service.currentUser?.uid ?? '',
      type: _selectedType,
      amount: amount,
      category: _selectedCategory,
      categoryName: _selectedCategoryName,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: DateTime.now(),
    );

    await service.addTransaction(newTx);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch Mới'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Chọn loại: Thu hay Chi
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(value: TransactionType.expense, label: Text('Khoản Chi (-)')),
              ButtonSegment(value: TransactionType.income, label: Text('Khoản Thu (+)')),
            ],
            selected: {_selectedType},
            onSelectionChanged: (set) {
              setState(() => _selectedType = set.first);
            },
          ),
          const SizedBox(height: 20),

          // Nhập số tiền
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Số tiền (VND)',
              suffixText: '₫',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Chọn Danh mục
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Danh mục',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(
                value: cat['id'],
                child: Text(cat['name']!),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                final found = _categories.firstWhere((c) => c['id'] == val);
                setState(() {
                  _selectedCategory = val;
                  _selectedCategoryName = found['name']!;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Ghi chú
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú / Diễn giải',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),

          // Nút Lưu lên Firebase
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Lưu lên Firebase', style: TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }
}

