import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirebaseExpenseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  double _monthlyBudget = 15000000;
  double get monthlyBudget => _monthlyBudget;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription? _txSubscription;

  Future<void> init() async {
    _auth.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user == null) {
        // Tự động đăng nhập ẩn danh nếu chưa có tài khoản
        await signInAnonymously();
      } else {
        await _listenToUserTransactions(user.uid);
        await _loadUserProfile(user.uid);
      }
      notifyListeners();
    });
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Lỗi đăng nhập ẩn danh: $e');
    }
  }

  Future<void> _listenToUserTransactions(String uid) async {
    _isLoading = true;
    notifyListeners();

    await _txSubscription?.cancel();

    // Lắng nghe Stream Firestore theo thời gian thực (Real-time sync)
    _txSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Lỗi Firestore Snapshot: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      _monthlyBudget = (data?['monthlyBudget'] as num?)?.toDouble() ?? 15000000;
      notifyListeners();
    }
  }

  // Thêm giao dịch mới lên Firebase
  Future<void> addTransaction(TransactionModel tx) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('transactions')
        .add(tx.toFirestore());
  }

  // Xóa giao dịch khỏi Firebase
  Future<void> deleteTransaction(String txId) async {
    if (_currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('transactions')
        .doc(txId)
        .delete();
  }

  // Cập nhật hạn mức ngân sách tháng
  Future<void> updateBudget(double newBudget) async {
    if (_currentUser == null) return;
    _monthlyBudget = newBudget;
    notifyListeners();
    await _firestore.collection('users').doc(_currentUser!.uid).set({
      'monthlyBudget': newBudget,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _txSubscription?.cancel();
    super.dispose();
  }
}