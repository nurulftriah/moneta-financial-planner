import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../classes/input_model.dart';
import '../classes/budget_model.dart';
import '../classes/saving_goal_model.dart';
import '../classes/recurring_transaction_model.dart';
import 'package:intl/intl.dart';

class FirestoreServices {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  static CollectionReference<Map<String, dynamic>>
      get _transactionsCollection =>
          _db.collection('users').doc(_userId).collection('transactions');

  static Future<void> addTransaction(InputModel transaction) async {
    if (_userId.isEmpty) return;
    final docRef = _transactionsCollection.doc();
    transaction.id = docRef.id;
    await docRef.set(transaction.toMap());
  }

  static Future<void> updateTransaction(InputModel transaction) async {
    if (_userId.isEmpty) return;
    if (transaction.id == null) return;
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  static Future<void> deleteTransaction(String id) async {
    if (_userId.isEmpty) return;
    await _transactionsCollection.doc(id).delete();
  }

  static Future<void> deleteAllTransactions() async {
    if (_userId.isEmpty) return;
    var snapshots = await _transactionsCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  static Stream<List<InputModel>> getTransactionsStream() {
    if (_userId.isEmpty) return Stream.value([]);
    return _transactionsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return InputModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Legacy support for Future-based retrieval if needed
  static Future<List<InputModel>> getTransactionsFuture() async {
    if (_userId.isEmpty) return [];
    var snapshot = await _transactionsCollection.get();
    return snapshot.docs.map((doc) {
      return InputModel.fromMap(doc.data());
    }).toList();
  }

  static CollectionReference<Map<String, dynamic>> get _budgetsCollection =>
      _db.collection('users').doc(_userId).collection('budgets');

  // Budget Methods
  static Future<void> addBudget(BudgetModel budget) async {
    if (_userId.isEmpty) return;
    final docRef = _budgetsCollection.doc();
    budget.id = docRef.id;
    await docRef.set(budget.toMap());
  }

  static Future<void> updateBudget(BudgetModel budget) async {
    if (_userId.isEmpty) return;
    if (budget.id == null) return;
    await _budgetsCollection.doc(budget.id).update(budget.toMap());
  }

  static Future<void> deleteBudget(String id) async {
    if (_userId.isEmpty) return;
    await _budgetsCollection.doc(id).delete();
  }

  static Stream<List<BudgetModel>> getBudgetsStream() {
    if (_userId.isEmpty) return Stream.value([]);
    return _budgetsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BudgetModel.fromMap(doc.data());
      }).toList();
    });
  }

  static CollectionReference<Map<String, dynamic>> get _savingGoalsCollection =>
      _db.collection('users').doc(_userId).collection('saving_goals');

  // Saving Goal Methods
  static Future<void> addSavingGoal(SavingGoalModel goal) async {
    if (_userId.isEmpty) return;
    final docRef = _savingGoalsCollection.doc();
    goal.id = docRef.id;
    await docRef.set(goal.toMap());
  }

  static Future<void> updateSavingGoal(SavingGoalModel goal) async {
    if (_userId.isEmpty) return;
    if (goal.id == null) return;
    await _savingGoalsCollection.doc(goal.id).update(goal.toMap());
  }

  static Future<void> deleteSavingGoal(String id) async {
    if (_userId.isEmpty) return;
    await _savingGoalsCollection.doc(id).delete();
  }

  static Stream<List<SavingGoalModel>> getSavingGoalsStream() {
    if (_userId.isEmpty) return Stream.value([]);
    return _savingGoalsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SavingGoalModel.fromMap(doc.data());
      }).toList();
    });
  }

  static CollectionReference<Map<String, dynamic>>
      get _recurringTransactionsCollection => _db
          .collection('users')
          .doc(_userId)
          .collection('recurring_transactions');

  // Recurring Transaction Methods
  static Future<void> addRecurringTransaction(
      RecurringTransactionModel recurring) async {
    if (_userId.isEmpty) return;
    final docRef = _recurringTransactionsCollection.doc();
    recurring.id = docRef.id;
    await docRef.set(recurring.toMap());
  }

  static Future<void> updateRecurringTransaction(
      RecurringTransactionModel recurring) async {
    if (_userId.isEmpty) return;
    if (recurring.id == null) return;
    await _recurringTransactionsCollection
        .doc(recurring.id)
        .update(recurring.toMap());
  }

  static Future<void> deleteRecurringTransaction(String id) async {
    if (_userId.isEmpty) return;
    await _recurringTransactionsCollection.doc(id).delete();
  }

  static Stream<List<RecurringTransactionModel>>
      getRecurringTransactionsStream() {
    if (_userId.isEmpty) return Stream.value([]);
    return _recurringTransactionsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RecurringTransactionModel.fromMap(doc.data());
      }).toList();
    });
  }

  static Future<void> processRecurringTransactions() async {
    if (_userId.isEmpty) return;

    // Get all enabled recurring transactions
    final snapshot = await _recurringTransactionsCollection
        .where('isEnabled', isEqualTo: true)
        .get();

    final recurringTransactions = snapshot.docs
        .map((doc) => RecurringTransactionModel.fromMap(doc.data()))
        .toList();

    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var recurring in recurringTransactions) {
      if (recurring.nextOccurrenceDate == null) continue;

      DateTime nextDate = dateFormat.parse(recurring.nextOccurrenceDate!);

      // Process if next occurrence is today or in the past
      bool processed = false;
      while (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
        // Create new transaction
        final newTransaction = InputModel(
          amount: recurring.amount,
          category: recurring.category,
          description: recurring.description ?? 'Recurring Transaction',
          date: dateFormat.format(nextDate),
          time: recurring.time ?? '00:00',
          type: recurring.type,
          color: recurring.color,
        );

        await addTransaction(newTransaction);

        // Calculate next date
        switch (recurring.frequency) {
          case 'Daily':
            nextDate = nextDate.add(Duration(days: 1));
            break;
          case 'Weekly':
            nextDate = nextDate.add(Duration(days: 7));
            break;
          case 'Monthly':
            nextDate =
                DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
            break;
          case 'Yearly':
            nextDate =
                DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
            break;
          default:
            nextDate = nextDate.add(Duration(days: 30)); // Default fallback
        }
        processed = true;
      }

      if (processed) {
        recurring.nextOccurrenceDate = dateFormat.format(nextDate);
        await updateRecurringTransaction(recurring);
      }
    }
  }
}
