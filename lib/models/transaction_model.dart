import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String category;
  final String categoryName;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryName,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  // Chuyển đổi DocumentSnapshot từ Firebase Firestore sang TransactionModel
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: (data['type'] == 'income') ? TransactionType.income : TransactionType.expense,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? 'other_expense',
      categoryName: data['categoryName'] ?? 'Khác',
      note: data['note'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }

  // Chuyển đổi Model thành Map JSON lưu lên Firebase Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'categoryName': categoryName,
      'note': note,
      'date': date.toIso8601String().substring(0, 10),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
