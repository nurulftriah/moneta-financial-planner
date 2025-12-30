import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_assistant_2608/project/auth_services/firebase_authentication.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import '../home.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoginLoading = false;
  bool _isRegisterLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _isLoginLoading = true);
      final user = await FirebaseAuthentication.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
        context: context,
      );
      setState(() => _isLoginLoading = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() => _isRegisterLoading = true);
      final user = await FirebaseAuthentication.registerWithEmailAndPassword(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        context: context,
      );
      setState(() => _isRegisterLoading = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final user = await FirebaseAuthentication.googleSignIn(context: context);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  void _showPasswordRecovery() {
    final emailController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'Reset Password') ??
                        'Reset Password',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(41, 98, 155, 1),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    getTranslated(context, 'Enter email for reset') ??
                        'Enter your email to receive password reset instructions',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: getTranslated(context, 'Email') ?? 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Color.fromRGBO(210, 234, 251, 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(139, 205, 254, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          customToast(
                              context,
                              getTranslated(context,
                                      'Please enter a valid email to reset password') ??
                                  'Please enter a valid email to reset password');
                          return;
                        }

                        try {
                          await FirebaseAuthentication.resetPassword(
                              email: email, context: context);
                          Navigator.pop(context);
                          customToast(
                              context,
                              getTranslated(
                                      context, 'Password reset email sent') ??
                                  'Password reset email sent. Check your inbox.');
                        } catch (e) {
                          // Error handled in service
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(89, 176, 222, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        getTranslated(context, 'Send Reset Link') ??
                            'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(210, 234, 251, 1), // blue1
              Color.fromRGBO(139, 205, 254, 1), // blue2
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title Section
                  Image.asset(
                    'images/logo.png',
                    height: 120.h,
                    width: 120.w,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Moneta',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(41, 98, 155, 1),
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Main Auth Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(89, 176, 222, 0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Tab Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(210, 234, 251, 0.5),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24.r),
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(89, 176, 222, 1),
                                      Color.fromRGBO(139, 205, 254, 1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor:
                                    Color.fromRGBO(89, 176, 222, 1),
                                labelStyle: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                                tabs: [
                                  Tab(
                                      text: getTranslated(context, 'LOGIN') ??
                                          'LOGIN'),
                                  Tab(
                                      text:
                                          getTranslated(context, 'REGISTER') ??
                                              'REGISTER'),
                                ],
                              ),
                            ),

                            // Tab Content
                            Container(
                              height: 450.h,
                              padding: EdgeInsets.all(24.w),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginTab(),
                                  _buildRegisterTab(),
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
    );
  }

  Widget _buildLoginTab() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _loginEmailController,
            label: getTranslated(context, 'Email') ?? 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return getTranslated(context, 'Please enter your email') ??
                    'Please enter your email';
              }
              if (!value.contains('@')) {
                return getTranslated(context, 'Please enter valid email') ??
                    'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _loginPasswordController,
            label: getTranslated(context, 'Password') ?? 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: Color.fromRGBO(89, 176, 222, 1),
              ),
              onPressed: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return getTranslated(context, 'Please enter your password') ??
                    'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showPasswordRecovery,
              child: Text(
                getTranslated(context, 'Forgot Password?') ??
                    'Forgot Password?',
                style: TextStyle(
                  color: Color.fromRGBO(89, 176, 222, 1),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildPrimaryButton(
            label: getTranslated(context, 'LOGIN') ?? 'LOGIN',
            isLoading: _isLoginLoading,
            onPressed: _handleLogin,
          ),
          SizedBox(height: 20.h),
          _buildDivider(),
          SizedBox(height: 20.h),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(
              controller: _registerEmailController,
              label: getTranslated(context, 'Email') ?? 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getTranslated(context, 'Please enter your email') ??
                      'Please enter your email';
                }
                if (!value.contains('@')) {
                  return getTranslated(context, 'Please enter valid email') ??
                      'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _registerPasswordController,
              label: getTranslated(context, 'Password') ?? 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscureRegisterPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Color.fromRGBO(89, 176, 222, 1),
                ),
                onPressed: () {
                  setState(() =>
                      _obscureRegisterPassword = !_obscureRegisterPassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getTranslated(context, 'Please enter a password') ??
                      'Please enter a password';
                }
                if (value.length < 6) {
                  return getTranslated(context, 'Password min length') ??
                      'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _confirmPasswordController,
              label: getTranslated(context, 'Confirm Password') ??
                  'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Color.fromRGBO(89, 176, 222, 1),
                ),
                onPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getTranslated(
                          context, 'Please confirm your password') ??
                      'Please confirm your password';
                }
                if (value != _registerPasswordController.text) {
                  return getTranslated(context, 'Passwords do not match') ??
                      'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            _buildPrimaryButton(
              label: getTranslated(context, 'REGISTER') ?? 'REGISTER',
              isLoading: _isRegisterLoading,
              onPressed: _handleRegister,
            ),
            SizedBox(height: 20.h),
            _buildDivider(),
            SizedBox(height: 20.h),
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color.fromRGBO(89, 176, 222, 1)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Color.fromRGBO(210, 234, 251, 0.5),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: Color.fromRGBO(89, 176, 222, 1),
        ),
        errorStyle: TextStyle(
          fontSize: 12.sp,
          color: Color.fromRGBO(217, 89, 89, 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(139, 205, 254, 1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(89, 176, 222, 1),
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(217, 89, 89, 1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(217, 89, 89, 1),
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(89, 176, 222, 1),
                Color.fromRGBO(139, 205, 254, 1),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Color.fromRGBO(89, 176, 222, 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            getTranslated(context, 'OR') ?? 'OR',
            style: TextStyle(
              color: Color.fromRGBO(89, 176, 222, 1),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color.fromRGBO(89, 176, 222, 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.google,
            label: getTranslated(context, 'Google') ?? 'Google',
            onPressed: _handleGoogleSignIn,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color.fromRGBO(139, 205, 254, 1),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Color.fromRGBO(89, 176, 222, 1),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(89, 176, 222, 1),
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
