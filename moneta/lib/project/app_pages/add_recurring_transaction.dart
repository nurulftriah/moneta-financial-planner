import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/classes/recurring_transaction_model.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:money_assistant_2608/project/app_pages/expense_category.dart';
import 'package:money_assistant_2608/project/app_pages/income_category.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../provider.dart';

class AddRecurringTransaction extends StatefulWidget {
  final RecurringTransactionModel? model;

  const AddRecurringTransaction({Key? key, this.model}) : super(key: key);

  @override
  _AddRecurringTransactionState createState() =>
      _AddRecurringTransactionState();
}

class _AddRecurringTransactionState extends State<AddRecurringTransaction> {
  final _formKey = GlobalKey<FormState>();
  late RecurringTransactionModel _model;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedFrequency;
  late DateTime _startDate;
  late String _type;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      _model = widget.model!;
      _selectedFrequency = _model.frequency ?? 'Monthly';
      _startDate = DateFormat('dd/MM/yyyy').parse(_model.startDate!);
      _type = _model.type ?? 'Expense';
    } else {
      _model = RecurringTransactionModel();
      _selectedFrequency = 'Monthly';
      _startDate = DateTime.now();
      _type = 'Expense';
      _model.type = _type;
      _model.category = 'Category';
    }

    _amountController = TextEditingController(
      text: _model.amount != null ? format(_model.amount!) : '',
    );
    _descriptionController =
        TextEditingController(text: _model.description ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_amountController.text.isEmpty) {
      customToast(context, 'Please enter an amount');
      return;
    }

    _model.amount = double.parse(_amountController.text.replaceAll(',', ''));
    _model.description = _descriptionController.text;
    _model.frequency = _selectedFrequency;
    _model.startDate = DateFormat('dd/MM/yyyy').format(_startDate);
    _model.nextOccurrenceDate ??=
        _model.startDate; // Set next occurrence if new
    _model.type = _type;
    // model.category is set in category picker

    if (widget.model == null) {
      await FirestoreServices.addRecurringTransaction(_model);
      customToast(context, 'Recurring transaction added');
    } else {
      await FirestoreServices.updateRecurringTransaction(_model);
      customToast(context, 'Recurring transaction updated');
    }
    Navigator.pop(context);
  }

  void _delete() async {
    if (_model.id != null) {
      await FirestoreServices.deleteRecurringTransaction(_model.id!);
      customToast(context, 'Recurring transaction deleted');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeCategoryA>(
        create: (context) => ChangeCategoryA(),
        builder: (context, _) {
          // Initialize category provider with current model category if available
          if (widget.model != null || _model.category != 'Category') {
            // This is a simplification. Ideally we map string to icon.
            // For now, we rely on the provider to hold the state after selection.
          }

          return Scaffold(
            backgroundColor: blue1,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: blue3,
              title: Text(
                widget.model == null
                    ? (getTranslated(context, 'Add Recurring') ??
                        'Add Recurring')
                    : (getTranslated(context, 'Edit Recurring') ??
                        'Edit Recurring'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (widget.model != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: _delete,
                  )
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'Expense'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: _type == 'Expense'
                                  ? red
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getTranslated(context, 'Expense') ?? 'Expense',
                              style: TextStyle(
                                color: _type == 'Expense' ? Colors.white : red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'Income'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: _type == 'Income'
                                  ? green
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              getTranslated(context, 'Income') ?? 'Income',
                              style: TextStyle(
                                color: _type == 'Income' ? Colors.white : green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Amount
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'Amount') ?? 'Amount',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14.sp),
                        ),
                        TextFormField(
                          controller: _amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: _type == 'Income' ? green : red,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.attach_money,
                                color: _type == 'Income' ? green : red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Category
                  Consumer<ChangeCategoryA>(
                      builder: (context, changeCategoryA, child) {
                    // Update model category when provider changes
                    if (changeCategoryA.categoryItemA != null) {
                      _model.category = changeCategoryA.categoryItemA!.text;
                    }

                    return GestureDetector(
                      onTap: () async {
                        CategoryItem newCategoryItem = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => _type == 'Income'
                                  ? IncomeCategory()
                                  : ExpenseCategory()),
                        );
                        changeCategoryA.changeCategory(newCategoryItem);
                      },
                      child: _buildCard(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: (_type == 'Income' ? green : red)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                // Simplified logic for icon, ideally should match category
                                Icons.category,
                                color: _type == 'Income' ? green : red,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              getTranslated(context, _model.category!) ??
                                  _model.category!,
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios,
                                size: 16.sp, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),

                  // Frequency
                  _buildCard(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        labelText:
                            getTranslated(context, 'Frequency') ?? 'Frequency',
                        border: InputBorder.none,
                      ),
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedFrequency = val!),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Start Date
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: _buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              getTranslated(context, 'Start Date') ??
                                  'Start Date',
                              style: TextStyle(fontSize: 16.sp)),
                          Text(DateFormat('dd/MM/yyyy').format(_startDate),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Description
                  _buildCard(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: getTranslated(context, 'Description') ??
                            'Description',
                        border: InputBorder.none,
                        icon: Icon(Icons.description, color: blue3),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Save Button
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r)),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      getTranslated(context, 'Save') ?? 'Save',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20.r),
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
