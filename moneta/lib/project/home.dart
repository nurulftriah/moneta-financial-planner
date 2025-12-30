import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:money_assistant_2608/project/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'app_pages/analysis.dart';
import 'app_pages/budget.dart';
import 'app_pages/input.dart';
import 'localization/methods.dart';
import 'app_pages/calendar.dart';
import 'app_pages/others.dart';
import 'database_management/firestore_services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> myBody = [
    AddInput(),
    Analysis(),
    BudgetPage(),
    Calendar(),
    Other(),
  ];
  BottomNavigationBarItem bottomNavigationBarItem(
          IconData iconData, String label) =>
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(bottom: 0.h),
          child: Icon(
            iconData,
          ),
        ),
        label: getTranslated(context, label),
      );

  @override
  void initState() {
    super.initState();
    FirestoreServices.processRecurringTransactions();
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> bottomItems = <BottomNavigationBarItem>[
      bottomNavigationBarItem(Icons.add, 'Input'),
      bottomNavigationBarItem(Icons.analytics_outlined, 'Analysis'),
      bottomNavigationBarItem(Icons.account_balance_wallet, 'Budget'),
      bottomNavigationBarItem(Icons.calendar_today, 'Calendar'),
      bottomNavigationBarItem(Icons.account_circle, 'Other'),
    ];

    return ChangeNotifierProvider<InputModelList>(
      create: (context) => InputModelList(),
      child: Scaffold(
        backgroundColor: blue1,
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                iconSize: 26.sp,
                selectedFontSize: 14.sp,
                unselectedFontSize: 12.sp,
                backgroundColor: Colors.transparent,
                selectedItemColor: Color.fromRGBO(89, 176, 222, 1), // blue3
                unselectedItemColor: Colors.black45,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                items: bottomItems,
                currentIndex: _selectedIndex,
                onTap: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
        body: myBody[_selectedIndex],
      ),
    );
  }
}
