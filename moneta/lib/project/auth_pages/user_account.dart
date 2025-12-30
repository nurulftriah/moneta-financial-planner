import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_assistant_2608/project/auth_pages/sign_in.dart';
import 'package:money_assistant_2608/project/auth_services/firebase_authentication.dart';

class UserAccount extends StatefulWidget {
  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  List<String> textList = [
    "Personal information",
    "Account link",
    "Change password",
    "Sign out"
  ];
  List<IconData> iconList = [
    Icons.person,
    Icons.link_sharp,
    Icons.admin_panel_settings_sharp,
    Icons.logout
  ];

  Color _getIconGradientColor(int index, bool isStart) {
    List<List<Color>> gradients = [
      [Color(0xFF4FC3F7), Color(0xFF0288D1)], // Personal info - blue
      [Color(0xFF4FC3F7), Color(0xFF0277BD)], // Account link - blue
      [Color(0xFF4FC3F7), Color(0xFF0288D1)], // Change password - blue
      [Color(0xFFEF5350), Color(0xFFC62828)], // Sign out - red
    ];

    if (index >= gradients.length) {
      return isStart ? Colors.blue.shade300 : Colors.blue.shade700;
    }

    return isStart ? gradients[index][0] : gradients[index][1];
  }

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
              expandedHeight: 320.h,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
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
                      padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 16.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 35.r,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        backgroundImage: user?.photoURL != null
                                            ? NetworkImage(user!.photoURL!)
                                            : null,
                                        child: user?.photoURL == null
                                            ? Icon(Icons.person,
                                                size: 35.sp,
                                                color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      user?.displayName ?? "User Name",
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (user?.email != null) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        user!.email!,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    SizedBox(height: 10.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.crop_free,
                                              color: Colors.white, size: 16.sp),
                                          SizedBox(width: 5.w),
                                          Text(
                                            "Free",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Premium Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD54F).withOpacity(0.3),
                                Color(0xFFFFA000).withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFFA000).withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 16.h),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFD54F),
                                            Color(0xFFFFA000),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.7),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFFFFA000)
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.sports_golf,
                                          size: 28.sp, color: Colors.white),
                                    ),
                                    SizedBox(width: 18.w),
                                    Expanded(
                                      child: Text(
                                        'Explore Premium',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18.sp,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Account Options
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: iconList.length,
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
                                      if (int == 3) {
                                        await FirebaseAuthentication.signOut(
                                            context: context);
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignIn()),
                                                (Route<dynamic> route) =>
                                                    false);
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
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  _getIconGradientColor(
                                                      int, true),
                                                  _getIconGradientColor(
                                                      int, false),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14.r),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getIconGradientColor(
                                                          int, false)
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(iconList[int],
                                                size: 24.sp,
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: Text(
                                              textList[int],
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
                                            color: Colors.black45,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
