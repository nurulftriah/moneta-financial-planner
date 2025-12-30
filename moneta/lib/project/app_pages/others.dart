import 'dart:core';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/app_pages/select_date_format.dart';
import 'package:money_assistant_2608/project/app_pages/select_language.dart';
import 'package:money_assistant_2608/project/app_pages/recurring_transactions_list.dart';
import 'package:money_assistant_2608/project/auth_pages/user_account.dart';
import 'package:money_assistant_2608/project/classes/alert_dialog.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/firestore_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import '../provider.dart';
import 'currency.dart';

class Other extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.h,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(89, 176, 222, 1), // blue3
                        Color.fromRGBO(139, 205, 254, 1), // blue2
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 35.r,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        backgroundImage: user?.photoURL != null
                                            ? NetworkImage(user!.photoURL!)
                                            : null,
                                        child: user?.photoURL == null
                                            ? Icon(
                                                FontAwesomeIcons.smileBeam,
                                                color: Colors.white,
                                                size: 35.sp,
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(width: 24.w),
                                    Expanded(
                                      child: Text(
                                        '${getTranslated(context, 'Hi') ?? 'Hi'} ${user?.displayName?.split(' ').first ?? 'there'}!',
                                        style: TextStyle(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ChangeNotifierProvider<OnSwitch>(
                create: (context) => OnSwitch(),
                builder: (context, widget) =>
                    Settings(providerContext: context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  final BuildContext providerContext;
  const Settings({required this.providerContext});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    List<Widget> pageRoute = [
      UserAccount(),
      RecurringTransactionsList(),
      SelectLanguage(),
      Currency(),
    ];
    List<Widget> settingsIcons = [
      Icon(
        Icons.account_circle,
        size: 35,
        color: Colors.lightBlue,
      ),
      Icon(
        Icons.repeat,
        size: 35,
        color: Colors.purpleAccent,
      ),
      // Icon(
      //   Icons.settings,
      //   size: 32,
      //   color: Colors.blueGrey[800],
      // ),
      // Icon(
      //   Icons.feedback,
      //   size: 35.sp,
      //   color: Colors.black54,
      // ),
      Icon(
        Icons.language,
        size: 32.sp,
        color: Colors.lightBlue,
      ),
      Icon(
        Icons.monetization_on,
        size: 32.sp,
        color: Colors.orangeAccent,
      ),
      Icon(Icons.format_align_center, size: 32.sp, color: Colors.lightBlue),
      Icon(Icons.refresh, size: 32.sp, color: Colors.lightBlue),
      Icon(Icons.delete_forever, size: 32.sp, color: red),
      // Icon(Icons.lock, size: 32.sp, color: Colors.blueGrey),
      Icon(
        Icons.share,
        size: 28.sp,
        color: Colors.lightBlue,
      ),
      Icon(
        Icons.star,
        size: 32.sp,
        color: Colors.amber,
      ),
    ];
    List<String> settingsList = [
      getTranslated(context, 'My Account')!,
      getTranslated(context, 'Recurring Transactions') ??
          'Recurring Transactions',
      // getTranslated(context, 'General Settings')!,
      // getTranslated(context, 'Feedback')!,
      getTranslated(context, 'Language') ?? 'Language',
      getTranslated(context, 'Currency') ?? 'Currency',
      (getTranslated(context, 'Date format') ?? 'Date format') +
          ' (${DateFormat(sharedPrefs.dateFormat).format(now)})',
      getTranslated(context, 'Reset All Categories') ?? 'Reset All Categories',
      getTranslated(context, 'Delete All Data') ?? 'Delete All Data',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: settingsList.length,
        itemBuilder: (context, int) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () async {
                        if ((int == 0) ||
                            (int == 1) ||
                            (int == 2) ||
                            (int == 3)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => pageRoute[int]),
                          );
                        } else if (int == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FormatDate()),
                          ).then((value) => setState(() {}));
                        } else if (int == 5) {
                          void onReset() {
                            sharedPrefs.setItems(setCategoriesToDefault: true);
                            customToast(context, 'Categories have been reset');
                          }

                          Platform.isIOS
                              ? await iosDialog(
                                  context,
                                  'This action cannot be undone. Are you sure you want to reset all categories?',
                                  'Reset',
                                  onReset)
                              : await androidDialog(
                                  context,
                                  'This action cannot be undone. Are you sure you want to reset all categories?',
                                  'reset',
                                  onReset);
                        } else if (int == 6) {
                          Future onDeletion() async {
                            await FirestoreServices.deleteAllTransactions();
                            customToast(context, 'All data has been deleted');
                          }

                          Platform.isIOS
                              ? await iosDialog(
                                  context,
                                  'Deleted data can not be recovered. Are you sure you want to delete all data?',
                                  'Delete',
                                  onDeletion)
                              : await androidDialog(
                                  context,
                                  'Deleted data can not be recovered. Are you sure you want to delete all data?',
                                  'Delete',
                                  onDeletion);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1,
                                ),
                              ),
                              child: settingsIcons[int],
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                settingsList[int],
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: Color.fromRGBO(89, 176, 222, 1)
                                  .withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class Upgrade extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Container(
//           height: 165.h,
//           color: Color.fromRGBO(234, 234, 234, 1),
//         ),
//         Container(
//           alignment: Alignment.center,
//           height: 115.h,
//           decoration: BoxDecoration(
//               image: DecorationImage(
//                   fit: BoxFit.fill, image: AssetImage('images/image13.jpg'))),
//         ),
//         Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//               color: Color.fromRGBO(255, 255, 255, 1),
//               borderRadius: BorderRadius.circular(40),
//               border: Border.all(
//                 color: Colors.grey,
//                 width: 0.5.w,
//               )),
//           height: 55.h,
//           width: 260.w,
//           child: Text(
//             getTranslated(context, 'VIEW UPGRADE OPTIONS')!,
//             style: TextStyle(fontSize: 4.206, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
// }
