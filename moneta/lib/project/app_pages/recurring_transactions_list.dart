import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/classes/recurring_transaction_model.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';
import 'add_recurring_transaction.dart';
import 'package:intl/intl.dart';

class RecurringTransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue1,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: blue3,
        title: Text(
          getTranslated(context, 'Recurring Transactions') ??
              'Recurring Transactions',
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
      ),
      body: StreamBuilder<List<RecurringTransactionModel>>(
        stream: FirestoreServices.getRecurringTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return Center(
              child: Text(
                getTranslated(context, 'No recurring transactions') ??
                    'No recurring transactions',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: transactions.length,
            padding: EdgeInsets.all(16.w),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'Income'
                        ? green.withOpacity(0.2)
                        : red.withOpacity(0.2),
                    child: Icon(
                      transaction.type == 'Income'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.type == 'Income' ? green : red,
                    ),
                  ),
                  title: Text(
                    transaction.description ?? 'No Description',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${transaction.frequency} - Next: ${transaction.nextOccurrenceDate}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    format(transaction.amount ?? 0),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: transaction.type == 'Income' ? green : red,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRecurringTransaction(
                          model: transaction,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecurringTransaction(),
            ),
          );
        },
        backgroundColor: blue3,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
