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

  final List<Map<String, dynamic>> _categories = [
    {'id': 'food', 'name': 'Ăn uống', 'icon': Icons.restaurant_rounded},
    {'id': 'transport', 'name': 'Đi lại', 'icon': Icons.directions_bus_rounded},
    {'id': 'shopping', 'name': 'Mua sắm', 'icon': Icons.shopping_bag_rounded},
    {'id': 'bills', 'name': 'Hóa đơn', 'icon': Icons.receipt_long_rounded},
    {'id': 'entertainment', 'name': 'Giải trí', 'icon': Icons.sports_esports_rounded},
    {'id': 'salary', 'name': 'Lương chính', 'icon': Icons.account_balance_wallet_rounded},
    {'id': 'freelance', 'name': 'Việc ngoài', 'icon': Icons.laptop_chromebook_rounded},
    {'id': 'other', 'name': 'Khác', 'icon': Icons.category_rounded},
  ];

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          behavior: SnackBarBehavior.floating,
        ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch Mới', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Segmented Button
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Khoản Chi (-)'),
                  icon: Icon(Icons.arrow_downward_rounded, color: Colors.redAccent),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Khoản Thu (+)'),
                  icon: Icon(Icons.arrow_upward_rounded, color: Colors.green),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) {
                setState(() => _selectedType = set.first);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Nhập Số Tiền
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Số tiền',
              prefixText: '₫ ',
              prefixStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pick Danh Mục dạng Grid
          const Text('Chọn danh mục', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['id'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat['id'];
                    _selectedCategoryName = cat['name'];
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.12) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['name'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Pick Ngày Tháng
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Ngày thực hiện: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ghi Chú
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Ghi chú / Diễn giải',
              prefixIcon: const Icon(Icons.notes_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),

          // Nút Lưu
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.cloud_upload_rounded),
              label: const Text('Lưu giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}