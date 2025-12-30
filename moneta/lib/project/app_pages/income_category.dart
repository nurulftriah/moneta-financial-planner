import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_assistant_2608/project/classes/app_bar.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:money_assistant_2608/project/provider.dart';
import 'package:provider/provider.dart';

import 'add_category.dart';
import 'edit_income_category.dart';

class IncomeCategory extends StatefulWidget {
  @override
  _IncomeCategoryState createState() => _IncomeCategoryState();
}

class _IncomeCategoryState extends State<IncomeCategory> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeIncomeItem>(
        create: (context) => ChangeIncomeItem(),
        child: Builder(
            builder: (buildContext) => Scaffold(
                extendBodyBehindAppBar: true, // Allow gradient behind app bar
                // backgroundColor: blue1, // Removed for gradient
                appBar: CategoryAppBar(EditIncomeCategory(buildContext)),
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        blue3,
                        blue1,
                      ],
                    ),
                  ),
                  child: IncomeCategoryBody(
                      context: buildContext, editIncomeCategory: false),
                ))));
  }
}

class IncomeCategoryBody extends StatefulWidget {
  final BuildContext? context, contextEdit;
  final bool editIncomeCategory;
  IncomeCategoryBody(
      {this.context, this.contextEdit, required this.editIncomeCategory});

  @override
  _IncomeCategoryBodyState createState() => _IncomeCategoryBodyState();
}

class _IncomeCategoryBodyState extends State<IncomeCategoryBody> {
  @override
  Widget build(BuildContext context) {
    var incomeList = widget.contextEdit == null
        ? Provider.of<ChangeIncomeItem>(widget.context!).incomeItems
        : Provider.of<ChangeIncomeItemEdit>(widget.contextEdit!).incomeItems;
    return Padding(
      padding: EdgeInsets.only(top: 0.h),
      child: SafeArea(
        child: ListView.builder(
          itemCount: incomeList.length,
          itemBuilder: (context, int) {
            return Padding(
              padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
              child: GestureDetector(
                onLongPress: () {
                  if (this.widget.editIncomeCategory) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCategory(
                                contextIn: widget.context,
                                contextInEdit: widget.contextEdit,
                                type: 'Income',
                                appBarTitle: 'Add Income Category',
                                categoryName: incomeList[int].text,
                                categoryIcon: iconData(incomeList[int]),
                                description: incomeList[int].description!)));
                  }
                },
                onTap: () {
                  if (this.widget.editIncomeCategory) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCategory(
                                contextIn: widget.context,
                                contextInEdit: widget.contextEdit,
                                type: 'Income',
                                appBarTitle: 'Add Income Category',
                                categoryName: incomeList[int].text,
                                categoryIcon: iconData(incomeList[int]),
                                description: incomeList[int].description!)));
                  } else {
                    Navigator.pop(context, incomeList[int]);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF002F6C)
                                .withOpacity(0.2), // Blue shadow
                            blurRadius: 15,
                            offset: Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 18.h, horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ]),
                            child: Icon(
                              iconData(incomeList[int]),
                              size: 28.sp,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          Expanded(
                            child: Text(
                              getTranslated(context, incomeList[int].text) ??
                                  incomeList[int].text,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    )
                                  ]),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 20.sp,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
