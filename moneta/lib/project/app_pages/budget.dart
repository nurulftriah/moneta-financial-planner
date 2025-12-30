import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/budget_model.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:money_assistant_2608/project/classes/app_bar.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';

import 'package:money_assistant_2608/project/classes/saving_goal_model.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(210, 234, 251, 1), // blue1
                Color.fromRGBO(230, 242, 252, 1),
              ],
            ),
          ),
          child: Column(
            children: [
              BasicAppBar(
                  getTranslated(context, 'Smart Budget') ?? 'Smart Budget'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Container(
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: blue3,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(text: getTranslated(context, 'Budgets') ?? 'Budgets'),
                      Tab(text: getTranslated(context, 'Goals') ?? 'Goals'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _BudgetsTab(),
                    _SavingGoalsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetsTab extends StatefulWidget {
  @override
  __BudgetsTabState createState() => __BudgetsTabState();
}

class __BudgetsTabState extends State<_BudgetsTab> {
  Map<String, double> _spendingByCategory = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<InputModel>>(
        stream: FirestoreServices.getTransactionsStream(),
        builder: (context, transactionSnapshot) {
          if (transactionSnapshot.hasData) {
            _calculateSpending(transactionSnapshot.data!);
          }

          return StreamBuilder<List<BudgetModel>>(
            stream: FirestoreServices.getBudgetsStream(),
            builder: (context, budgetSnapshot) {
              if (!budgetSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final budgets = budgetSnapshot.data!;
              if (budgets.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 80.h),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final spent = _spendingByCategory[budget.category] ?? 0.0;
                  return _buildBudgetCard(budget, spent);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetModal(context),
        backgroundColor: blue3,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _calculateSpending(List<InputModel> transactions) {
    _spendingByCategory.clear();
    final now = DateTime.now();

    for (var transaction in transactions) {
      final date = DateFormat('dd/MM/yyyy').parse(transaction.date!);
      if (transaction.type == 'Expense' &&
          date.month == now.month &&
          date.year == now.year) {
        final category = transaction.category!;
        _spendingByCategory[category] =
            (_spendingByCategory[category] ?? 0) + transaction.amount!;
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64.sp, color: Colors.black26),
          SizedBox(height: 16.h),
          Text(
            getTranslated(context, 'No budgets set yet') ??
                'No budgets set yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black45,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            getTranslated(context, 'Tap + to create a budget') ??
                'Tap + to create a budget',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget, double spent) {
    final progress = (spent / budget.amount).clamp(0.0, 1.0);
    final isExceeded = spent > budget.amount;

    Color statusColor;
    if (progress >= 1.0) {
      statusColor = Colors.redAccent;
    } else if (progress >= 0.8) {
      statusColor = Colors.orangeAccent;
    } else {
      statusColor = Colors.green;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        getTranslated(context, budget.category) ??
                            budget.category,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.sp, color: Colors.grey),
                      onPressed: () =>
                          _showAddBudgetModal(context, budgetToEdit: budget),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: 12.w),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 20.sp, color: Colors.red[300]),
                      onPressed: () =>
                          FirestoreServices.deleteBudget(budget.id!),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currency ${format(spent)} ${getTranslated(context, 'spent') ?? 'spent'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${getTranslated(context, 'Limit') ?? 'Limit'}: $currency ${format(budget.amount)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Stack(
                  children: [
                    Container(
                      height: 8.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4.r),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
                if (isExceeded)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      '${getTranslated(context, 'Budget exceeded by') ?? 'Budget exceeded by'} $currency ${format(spent - budget.amount)}',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
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

  void _showAddBudgetModal(BuildContext context, {BudgetModel? budgetToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddBudgetModal(budgetToEdit: budgetToEdit),
    );
  }
}

class _SavingGoalsTab extends StatefulWidget {
  @override
  __SavingGoalsTabState createState() => __SavingGoalsTabState();
}

class __SavingGoalsTabState extends State<_SavingGoalsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<SavingGoalModel>>(
        stream: FirestoreServices.getSavingGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data ?? [];
          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.only(bottom: 80.h, top: 10.h),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return _buildGoalCard(goals[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalModal(context),
        backgroundColor: blue3,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 64.sp, color: Colors.black26),
          SizedBox(height: 16.h),
          Text(
            getTranslated(context, 'No saving goals yet') ??
                'No saving goals yet',
            style: TextStyle(fontSize: 16.sp, color: Colors.black45),
          ),
          SizedBox(height: 8.h),
          Text(
            getTranslated(context, 'Tap + to start saving') ??
                'Tap + to start saving',
            style: TextStyle(fontSize: 14.sp, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingGoalModel goal) {
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24.r),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Color(goal.color).withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Color(goal.color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            goal.iconCodePoint != null
                                ? IconData(
                                    goal.iconCodePoint!,
                                    fontFamily: goal.iconFontFamily,
                                    fontPackage: goal.iconFontPackage,
                                  )
                                : Icons.savings,
                            color: Color(goal.color),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (goal.targetDate != null)
                              Text(
                                'Target: ${DateFormat('dd MMM yyyy').format(DateTime.parse(goal.targetDate!))}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddGoalModal(context, goalToEdit: goal);
                        } else if (value == 'delete') {
                          FirestoreServices.deleteSavingGoal(goal.id!);
                        } else if (value == 'add_funds') {
                          _showAddFundsDialog(context, goal);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'add_funds',
                          child: Text(getTranslated(context, 'Add Funds') ??
                              'Add Funds'),
                        ),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(getTranslated(context, 'Edit') ?? 'Edit'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                              getTranslated(context, 'Delete') ?? 'Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currency ${format(goal.currentAmount)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(goal.color),
                      ),
                    ),
                    Text(
                      '${getTranslated(context, 'Goal: ') ?? 'Goal: '} $currency ${format(goal.targetAmount)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Stack(
                  children: [
                    Container(
                      height: 10.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Color(goal.color),
                          borderRadius: BorderRadius.circular(5.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(goal.color).withOpacity(0.4),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddGoalModal(BuildContext context, {SavingGoalModel? goalToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSavingGoalModal(goalToEdit: goalToEdit),
    );
  }

  void _showAddFundsDialog(BuildContext context, SavingGoalModel goal) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  "${getTranslated(context, 'Add Funds to') ?? 'Add Funds to'} ${goal.name}"),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: getTranslated(context, 'Amount') ?? 'Amount',
                  prefixText: "$currency ",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(getTranslated(context, 'Cancel') ?? "Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text) ?? 0.0;
                    if (amount > 0) {
                      goal.currentAmount += amount;
                      FirestoreServices.updateSavingGoal(goal);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(getTranslated(context, 'Save') ?? "Save"),
                ),
              ],
            ));
  }
}

class _AddBudgetModal extends StatefulWidget {
  final BudgetModel? budgetToEdit;

  const _AddBudgetModal({Key? key, this.budgetToEdit}) : super(key: key);

  @override
  __AddBudgetModalState createState() => __AddBudgetModalState();
}

class __AddBudgetModalState extends State<_AddBudgetModal> {
  final _amountController = TextEditingController();
  late String _selectedCategory;
  List<CategoryItem> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.budgetToEdit != null) {
      _amountController.text = (widget.budgetToEdit!.amount)
          .toInt()
          .toString(); // As integer usually
    }
  }

  void _loadCategories() {
    // Flatten the categories list from sharedPrefs
    final allLists = sharedPrefs.getAllExpenseItemsLists();
    final allCategories = allLists.expand((list) => list).toList();

    // Deduplicate by text
    final seen = <String>{};
    _availableCategories =
        allCategories.where((c) => seen.add(c.text)).toList();

    if (_availableCategories.isNotEmpty) {
      if (widget.budgetToEdit != null) {
        // Verify the edited category still exists, if not, default to first or keep it if we want to allow legacy?
        // Use case: deleted category. Ideally we shouldn't allow editing a budget for a deleted category easily or show it differently.
        // For now, if exact match found, good.
        if (!_availableCategories
            .any((c) => c.text == widget.budgetToEdit!.category)) {
          // If not found, maybe add a temporary item or default to first?
          // Let's default to first to avoid crash, or add it to list?
          // Safest to default to first for now to prevent crash.
          _selectedCategory = _availableCategories.first.text;
        } else {
          _selectedCategory = widget.budgetToEdit!.category;
        }
      } else {
        _selectedCategory = _availableCategories.first.text;
      }
    } else {
      _selectedCategory = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  widget.budgetToEdit != null
                      ? getTranslated(context, 'Edit Budget') ?? 'Edit Budget'
                      : getTranslated(context, 'New Budget') ?? 'New Budget',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: blue3,
                  ),
                ),
                SizedBox(height: 24.h),

                // Category Dropdown
                Text(
                  getTranslated(context, 'Category') ?? 'Category',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: _availableCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.text,
                          child: Row(
                            children: [
                              Icon(
                                IconData(
                                  category.iconCodePoint,
                                  fontFamily: category.iconFontFamily,
                                  fontPackage: category.iconFontPackage,
                                ),
                                size: 20.sp,
                                color: blue3,
                              ),
                              SizedBox(width: 12.w),
                              Text(getTranslated(context, category.text) ??
                                  category.text),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: widget.budgetToEdit == null
                          ? (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            }
                          : null, // Disable category change for edit to simplify
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Amount Input
                Text(
                  getTranslated(context, 'Monthly Budget Limit') ??
                      'Monthly Budget Limit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixText: '$currency ',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                ),

                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue3,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      getTranslated(context, 'Save Budget') ?? 'Save Budget',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final budget = BudgetModel(
      id: widget.budgetToEdit?.id,
      category: _selectedCategory,
      amount: amount,
    );

    if (widget.budgetToEdit != null) {
      FirestoreServices.updateBudget(budget);
    } else {
      FirestoreServices.addBudget(budget);
    }

    Navigator.pop(context);
  }
}

class _AddSavingGoalModal extends StatefulWidget {
  final SavingGoalModel? goalToEdit;

  const _AddSavingGoalModal({Key? key, this.goalToEdit}) : super(key: key);

  @override
  __AddSavingGoalModalState createState() => __AddSavingGoalModalState();
}

class __AddSavingGoalModalState extends State<_AddSavingGoalModal> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _selectedDate;
  int _selectedColor = 0xFF2196F3; // Default Blue

  final List<int> _colors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFFF9800, // Orange
    0xFFF44336, // Red
    0xFF9C27B0, // Purple
    0xFFE91E63, // Pink
    0xFF009688, // Teal
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _nameController.text = widget.goalToEdit!.name;
      _targetController.text =
          widget.goalToEdit!.targetAmount.toInt().toString();
      _currentController.text =
          widget.goalToEdit!.currentAmount.toInt().toString();
      if (widget.goalToEdit!.targetDate != null) {
        _selectedDate = DateTime.parse(widget.goalToEdit!.targetDate!);
      }
      _selectedColor = widget.goalToEdit!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.goalToEdit != null
                        ? getTranslated(context, 'Edit Goal') ?? 'Edit Goal'
                        : getTranslated(context, 'New Goal') ?? 'New Goal',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: blue3,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Name Input
                  Text(
                    getTranslated(context, 'Goal Name') ?? 'Goal Name',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                        getTranslated(context, 'e.g. New Laptop') ??
                            'e.g. New Laptop'),
                  ),
                  SizedBox(height: 16.h),

                  // Target Amount
                  Text(
                    getTranslated(context, 'Target Amount') ?? 'Target Amount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('0', prefix: '$currency '),
                  ),
                  SizedBox(height: 16.h),

                  // Current Amount (only for new goals or if user wants to adjust)
                  Text(
                    getTranslated(context, 'Current Saved Amount') ??
                        'Current Saved Amount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _currentController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('0', prefix: '$currency '),
                  ),
                  SizedBox(height: 16.h),

                  // Target Date
                  Text(
                    getTranslated(context, 'Target Date (Optional)') ??
                        'Target Date (Optional)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ??
                            DateTime.now().add(Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: blue3, size: 20.sp),
                          SizedBox(width: 12.w),
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(_selectedDate!)
                                : getTranslated(context, 'Select Date') ??
                                    'Select Date',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Color Picker
                  Text(
                    getTranslated(context, 'Color') ?? 'Color',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: _colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(color: Colors.black54, width: 2)
                                : null,
                          ),
                          child: _selectedColor == color
                              ? Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 32.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue3,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.goalToEdit != null
                            ? getTranslated(context, 'Update Goal') ??
                                'Update Goal'
                            : getTranslated(context, 'Create Goal') ??
                                'Create Goal',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  void _saveGoal() {
    if (_nameController.text.isEmpty) return;
    if (_targetController.text.isEmpty) return;

    final name = _nameController.text;
    final target = double.tryParse(_targetController.text) ?? 0.0;
    final current = double.tryParse(_currentController.text) ?? 0.0;

    if (target <= 0) return;

    final goal = SavingGoalModel(
      id: widget.goalToEdit?.id,
      name: name,
      targetAmount: target,
      currentAmount: current,
      targetDate: _selectedDate?.toIso8601String(),
      color: _selectedColor,
    );

    if (widget.goalToEdit != null) {
      FirestoreServices.updateSavingGoal(goal);
    } else {
      FirestoreServices.addSavingGoal(goal);
    }

    Navigator.pop(context);
  }
}
