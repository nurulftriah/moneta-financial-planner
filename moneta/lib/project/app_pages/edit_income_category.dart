import 'package:flutter/material.dart';
import 'package:money_assistant_2608'
    '/project/classes/app_bar.dart';

import 'package:money_assistant_2608'
    '/project/localization/methods.dart';
import 'package:provider/provider.dart';
import '../classes/constants.dart';
import '../provider.dart';
import 'add_category.dart';
import 'income_category.dart';

class EditIncomeCategory extends StatelessWidget {
  final BuildContext? buildContext;
  EditIncomeCategory(this.buildContext);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeIncomeItemEdit>(
        create: (context) => ChangeIncomeItemEdit(),
        child: Builder(
            builder: (contextEdit) => Scaffold(
                extendBodyBehindAppBar: true,
                // backgroundColor: blue1,
                appBar: EditCategoryAppBar(
                  AddCategory(
                      contextIn: this.buildContext,
                      contextInEdit: contextEdit,
                      type: 'Income',
                      appBarTitle:
                          getTranslated(context, 'Add Income Category')!,
                      description: ''),
                ),
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
                        context: this.buildContext,
                        contextEdit: contextEdit,
                        editIncomeCategory: true)))));
  }
}
