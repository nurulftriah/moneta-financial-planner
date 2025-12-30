import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/app_bar.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/chart_pie.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/dropdown_box.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import 'report.dart';

final List<InputModel> chartDataNull = [
  InputModel(
      id: null,
      type: null,
      amount: 1,
      category: '',
      description: null,
      date: null,
      time: null,
      color: const Color.fromRGBO(0, 220, 252, 1))
];

class Analysis extends StatefulWidget {
  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeSelectedDate>(
      create: (context) => ChangeSelectedDate(),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            backgroundColor: blue1,
            appBar: InExAppBar(false),
            body: Selector<ChangeSelectedDate, String?>(
                selector: (_, changeSelectedDate) =>
                    changeSelectedDate.selectedAnalysisDate,
                builder: (context, selectedAnalysisDate, child) {
                  selectedAnalysisDate ??= sharedPrefs.selectedDate;
                  ListView listViewChild(String type) => ListView(
                        children: [
                          ShowDate(true, selectedAnalysisDate!),
                          ShowDetails(type, selectedAnalysisDate),
                        ],
                      );
                  return TabBarView(
                    children: [
                      listViewChild('Expense'),
                      listViewChild('Income')
                    ],
                  );
                })),
      ),
    );
  }
}

class ShowDate extends StatelessWidget {
  final bool forAnalysis;
  final String selectedDate;
  const ShowDate(this.forAnalysis, this.selectedDate);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(89, 176, 222, 0.9), // blue3 with transparency
                  Color.fromRGBO(139, 205, 254, 0.9), // blue2 with transparency
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 14.w),
                  DateDisplay(this.selectedDate),
                  Spacer(),
                  DropDownBox(this.forAnalysis, this.selectedDate)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateDisplay extends StatelessWidget {
  final String selectedDate;
  DateDisplay(this.selectedDate);

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat(sharedPrefs.dateFormat).format(todayDT);
    String since = getTranslated(context, 'Since')!;
    TextStyle style = GoogleFonts.poppins(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    Map<String, Widget> dateMap = {
      'Today': Text('$today', style: style),
      'This week': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisWeek)}',
        style: style,
      ),
      'This month': Text(
          '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisMonth)}',
          style: style),
      'This quarter': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisQuarter)}',
        style: style,
      ),
      'This year': Text(
        '$since ${DateFormat(sharedPrefs.dateFormat).format(startOfThisYear)}',
        style: style,
      ),
      'All': Text('${getTranslated(context, 'All')!}', style: style)
    };
    var dateListKey = dateMap.keys.toList();
    var dateListValue = dateMap.values.toList();

    for (int i = 0; i < dateListKey.length; i++) {
      if (selectedDate == dateListKey[i]) {
        return dateListValue[i];
      }
    }
    return Container();
  }
}

class ShowMoneyFrame extends StatelessWidget {
  final String type;
  final double typeValue, balance;
  const ShowMoneyFrame(this.type, this.typeValue, this.balance);

  @override
  Widget build(BuildContext context) {
    final Color typeColor = this.type == 'Income' ? green : red;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        children: [
          // Type Card (Income/Expense)
          _buildMetricCard(
            label: getTranslated(context, this.type)!,
            value: typeValue,
            icon:
                this.type == 'Income' ? Icons.trending_up : Icons.trending_down,
            gradient: this.type == 'Income'
                ? [
                    Color.fromRGBO(46, 125, 50, 1),
                    Color.fromRGBO(76, 175, 80, 1)
                  ]
                : [
                    Color.fromRGBO(198, 40, 40, 1),
                    Color.fromRGBO(244, 67, 54, 1)
                  ],
          ),
          SizedBox(height: 12.h),
          // Balance Card
          _buildMetricCard(
            label: getTranslated(context, 'Balance')!,
            value: this.balance,
            icon: Icons.account_balance_wallet,
            gradient: [
              Color.fromRGBO(25, 118, 210, 1),
              Color.fromRGBO(66, 165, 245, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required double value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient.map((c) => c.withOpacity(0.9)).toList(),
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        currency + ' ' + format(value),
                        style: GoogleFonts.poppins(
                          fontSize: format(value).length > 12 ? 28.sp : 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowDetails extends StatefulWidget {
  final String type, selectedDate;
  ShowDetails(this.type, this.selectedDate);

  @override
  _ShowDetailsState createState() => _ShowDetailsState();
}

class _ShowDetailsState extends State<ShowDetails> {
  Widget showInExDetails(
    BuildContext context,
    List<InputModel> transactionsSorted,
  ) {
    List<CategoryItem> itemList = widget.type == 'Income'
        ? createItemList(
            transactions: transactionsSorted,
            forAnalysisPage: true,
            isIncomeType: true,
            forSelectIconPage: false)
        : createItemList(
            transactions: transactionsSorted,
            forAnalysisPage: true,
            isIncomeType: false,
            forSelectIconPage: false);

    return Column(
        children: List.generate(itemList.length, (int) {
      return
          // SwipeActionCell(
          // backgroundColor: Colors.transparent,
          //   key: ObjectKey(transactionsSorted[int]),
          //   performsFirstActionWithFullSwipe: true,
          //   trailingActions: <SwipeAction>[
          //     SwipeAction(
          //         title: "Delete",
          //         onTap: (CompletionHandler handler) async {
          //           Future<void> onDeletion() async {
          //             await handler(true);
          //             transactionsSorted.removeAt(int);
          //             customToast(context, 'Transactions has been deleted');
          //             setState(() {});
          //           }
          //
          //           Platform.isIOS
          //               ? await iosDialog(
          //                   context,
          //                   'Deleted data can not be recovered. Are you sure you want to Delete All Transactions In This Category?',
          //                   'Delete',
          //                   onDeletion)
          //               : await androidDialog(
          //                   context,
          //                   'Deleted data can not be recovered. Are you sure you want to Delete All Transactions In This Category?',
          //                   'Delete',
          //                   onDeletion);
          //         },
          //         color: red),
          //   ], child:
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Report(
                              type: widget.type,
                              category: itemList[int].text,
                              selectedDate: widget.selectedDate,
                              icon: iconData(itemList[int]),
                            ))).then((value) => setState(() {}));
              },
              child: CategoryDetails(
                  widget.type,
                  getTranslated(context, itemList[int].text) ??
                      itemList[int].text,
                  transactionsSorted[int].amount!,
                  transactionsSorted[int].color,
                  iconData(itemList[int]),
                  false));
    }));
  }

  @override
  Widget build(BuildContext context) {
    late Map<String, double> chartDataMap;
    return StreamBuilder<List<InputModel>>(
        initialData: [],
        stream: Provider.of<InputModelList>(context).inputModelStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<InputModel>> snapshot) {
          connectionUI(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShowNullDetail(0, null, this.widget.type, false);
          }
          if (snapshot.data == null) {
            return ShowNullDetail(0, chartDataNull, this.widget.type, true);
          } else {
            double income = 0, expense = 0, balance = 0;

            List<InputModel> allTransactions =
                filterData(context, snapshot.data!, widget.selectedDate);

            if (allTransactions.length > 0) {
              //prepare for MoneyFrame

              List<double?> incomeList = [], expenseList = [];
              incomeList = allTransactions
                  .map((data) {
                    if (data.type == 'Income') {
                      return data.amount;
                    }
                  })
                  .where((element) => element != null)
                  .toList();

              expenseList = allTransactions
                  .map((data) {
                    if (data.type == 'Expense') {
                      return data.amount;
                    }
                  })
                  .where((element) => element != null)
                  .toList();

              if (incomeList.length > 0) {
                for (int i = 0; i < incomeList.length; i++) {
                  income = income + incomeList[i]!;
                }
              }
              if (expenseList.length > 0) {
                for (int i = 0; i < expenseList.length; i++) {
                  expense = expense + expenseList[i]!;
                }
              }
              balance = income - expense;

              // prepare for InExDetails
              if (this.widget.type == 'Income') {
                allTransactions = allTransactions
                    .map((data) {
                      if (data.type == 'Income') {
                        return inputModel(data);
                      }
                    })
                    .where((element) => element != null)
                    .cast<InputModel>()
                    .toList();
              } else {
                allTransactions = allTransactions
                    .map((data) {
                      if (data.type == 'Expense') {
                        return inputModel(data);
                      }
                    })
                    .where((element) => element != null)
                    .cast<InputModel>()
                    .toList();
              }
            }

            if (allTransactions.length == 0) {
              return ShowNullDetail(
                  balance, chartDataNull, this.widget.type, true);
            } else {
              List<InputModel> transactionsSorted = [
                InputModel(
                  type: this.widget.type,
                  amount: allTransactions[0].amount,
                  category: allTransactions[0].category,
                )
              ];

              int i = 1;
              //cmt: chartDataListDetailed.length must be greater than 2 to execute
              while (i < allTransactions.length) {
                allTransactions
                    .sort((a, b) => a.category!.compareTo(b.category!));

                if (i == 1) {
                  chartDataMap = {
                    allTransactions[0].category!: allTransactions[0].amount!
                  };
                }

                if (allTransactions[i].category ==
                    allTransactions[i - 1].category) {
                  chartDataMap.update(allTransactions[i].category!,
                      (value) => (value + allTransactions[i].amount!),
                      ifAbsent: () => (allTransactions[i - 1].amount! +
                          allTransactions[i].amount!));
                  i++;
                } else {
                  chartDataMap.addAll({
                    allTransactions[i].category!: allTransactions[i].amount!
                  });

                  i++;
                }
                transactionsSorted = chartDataMap.entries
                    .map((entry) => InputModel(
                          type: this.widget.type,
                          category: entry.key,
                          amount: entry.value,
                        ))
                    .toList();
              }

              void recurringFunc({required int i, n}) {
                if (n > i) {
                  for (int c = 1; c <= n - i; c++) {
                    transactionsSorted[i + c - 1].color = chartPieColors[c - 1];
                    recurringFunc(i: i, n: c);
                  }
                }
              }

              for (int n = 1; n <= transactionsSorted.length; n++) {
                transactionsSorted[n - 1].color = chartPieColors[n - 1];
                recurringFunc(i: chartPieColors.length, n: n);
              }
              return Column(
                children: [
                  ShowMoneyFrame(this.widget.type,
                      this.widget.type == 'Income' ? income : expense, balance),
                  SizedBox(height: 360.h, child: ChartPie(transactionsSorted)),
                  showInExDetails(
                    context,
                    // sum value of transactions having a same category to one
                    transactionsSorted,
                  )
                ],
              );
            }
          }
        });
  }
}

class ShowNullDetail extends StatelessWidget {
  final double balanceValue;
  final List<InputModel>? chartData;
  final String type;
  final bool connection;
  ShowNullDetail(this.balanceValue, this.chartData, this.type, this.connection);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShowMoneyFrame(this.type, 0, this.balanceValue),
        SizedBox(
            height: 360.h,
            child: connection == false ? null : ChartPie(this.chartData!)),
        CategoryDetails(
            this.type,
            getTranslated(context, 'Category') ?? 'Category',
            0,
            this.type == 'Income' ? green : red,
            Icons.category_outlined,
            true)
      ],
    );
  }
}

class CategoryDetails extends StatelessWidget {
  final String type, category;
  final double amount;
  final Color? color;
  final IconData icon;
  final bool forNullDetail;
  CategoryDetails(this.type, this.category, this.amount, this.color, this.icon,
      this.forNullDetail);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (forNullDetail
                                  ? (this.type == 'Income' ? green : red)
                                  : this.color ?? Colors.grey)
                              .withOpacity(0.8),
                          forNullDetail
                              ? (this.type == 'Income' ? green : red)
                              : this.color ?? Colors.grey,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: (forNullDetail
                                      ? (this.type == 'Income' ? green : red)
                                      : this.color ?? Colors.grey)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              this.icon,
                              color: forNullDetail
                                  ? (this.type == 'Income' ? green : red)
                                  : this.color,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  this.category,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currency,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: forNullDetail
                                      ? (this.type == 'Income' ? green : red)
                                      : this.color,
                                ),
                              ),
                              Text(
                                format(amount),
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: forNullDetail
                                      ? (this.type == 'Income' ? green : red)
                                      : this.color,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                          if (!forNullDetail) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: Colors.black38,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
