import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool submitting = false;

  String error = '';
  String email = '';
  String code = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      email = arguments['email']?.toString() ?? '';
      code = arguments['code']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String getPasswordValidationError(String value) {
    if (value.isEmpty) {
      return 'This field is required';
    }

    if (RegExp(r'\s').hasMatch(value) || RegExp(r'[^A-Za-z\d]').hasMatch(value)) {
      return 'Password must not contain spaces or special characters.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }

    return '';
  }

  Future<void> handleResetPassword() async {
    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
    });

    if (email.isEmpty || code.isEmpty) {
      setState(() {
        error = 'Reset session is missing. Please request a new OTP.';
      });

      return;
    }

    final newPasswordError = getPasswordValidationError(newPasswordController.text);

    if (newPasswordError.isNotEmpty) {
      setState(() {
        error = newPasswordError;
      });

      return;
    }

    final confirmPasswordError = getPasswordValidationError(confirmPasswordController.text);

    if (confirmPasswordError.isNotEmpty) {
      setState(() {
        error = confirmPasswordError;
      });

      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        error = 'Passwords do not match.';
      });

      return;
    }

    setState(() {
      submitting = true;
    });

    await Future.delayed(Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      submitting = false;
    });

    Navigator.pushReplacementNamed(
      context,
      '/login',
      arguments: {
        'prefilledEmail': email,
        'resetSuccess': true,
      },
    );
  }

  void goBackToForgotPassword() {
    if (submitting) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/forgot-password',
      arguments: {
        'prefilledEmail': email,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLogoSection(),
                buildResetCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogoSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Image.asset('assets/images/clinic-logo.jpg', width: 125, height: 125, fit: BoxFit.contain),
          SizedBox(height: 4),
          Text('ToothConnect', style: TextStyle(inherit: true, fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFB47A00), fontFamily: 'Arial')),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text('Your dental care, connected.', style: TextStyle(inherit: true, fontSize: 13, color: Color(0xFF1F1F1F), fontFamily: 'Arial')),
          ),
          Container(width: 195, height: 2, decoration: BoxDecoration(color: Color(0xFFC88A11), borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget buildResetCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 340),
      padding: EdgeInsets.only(left: 34, right: 34, top: 48, bottom: 46),
      decoration: BoxDecoration(
        color: Color(0xFFE4CF88),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          buildBackButton(),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'RESET PASSWORD',
                    textAlign: TextAlign.center,
                    style: TextStyle(inherit: true, fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC78300), fontFamily: 'Arial'),
                  ),
                ),
                SizedBox(height: 14),
                Container(width: double.infinity, height: 1.2, margin: EdgeInsets.only(bottom: 20), color: Color(0xFFB98212)),
                buildLabel('New Password'),
                buildPasswordInput(
                  controller: newPasswordController,
                  showPassword: showNewPassword,
                  onToggle: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                ),
                buildLabel('Confirm Password'),
                buildPasswordInput(
                  controller: confirmPasswordController,
                  showPassword: showConfirmPassword,
                  onToggle: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),
                if (error.isNotEmpty) buildErrorBox(),
                buildResetButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return Positioned(
      top: -32,
      left: -18,
      child: SizedBox(
        width: 40,
        height: 40,
        child: ElevatedButton(
          onPressed: submitting ? null : goBackToForgotPassword,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) => states.contains(WidgetState.disabled) ? Color(0xFFC98904).withValues(alpha: 0.7) : Color(0xFFC98904),
            ),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(CircleBorder()),
          ),
          child: Text('‹', style: TextStyle(inherit: true, color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1, fontFamily: 'Arial')),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 6),
      child: Text(text, style: TextStyle(inherit: true, fontSize: 19, color: Color(0xFF8B6508), fontWeight: FontWeight.w900, fontFamily: 'Arial')),
    );
  }

  Widget buildPasswordInput({required TextEditingController controller, required bool showPassword, required VoidCallback onToggle}) {
    return Container(
      width: double.infinity,
      height: 46,
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !showPassword,
              enabled: !submitting,
              onChanged: (_) {
                if (error.isNotEmpty) {
                  setState(() {
                    error = '';
                  });
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: TextStyle(inherit: true, fontSize: 15, color: Color(0xFF2F2F2F), fontFamily: 'Arial'),
            ),
          ),
          SizedBox(
            width: 55,
            height: 46,
            child: TextButton(
              onPressed: submitting ? null : onToggle,
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: WidgetStatePropertyAll(Size(55, 46)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.disabled) ? Color(0xFFB77C00).withValues(alpha: 0.5) : Color(0xFFB77C00),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(inherit: true, color: Color(0xFFB77C00), fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
                ),
              ),
              child: Text(showPassword ? 'Hide' : 'Show'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorBox() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12, bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(6)),
      child: Text(error, textAlign: TextAlign.center, style: TextStyle(inherit: true, color: Color(0xFF9B2C2C), fontSize: 13, fontFamily: 'Arial')),
    );
  }

  Widget buildResetButton() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.86,
        child: Container(
          margin: EdgeInsets.only(top: 26),
          child: ElevatedButton(
            onPressed: submitting ? null : handleResetPassword,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.disabled) ? Color(0xFFC98904).withValues(alpha: 0.7) : Color(0xFFC98904),
              ),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              elevation: WidgetStatePropertyAll(0),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 13)),
              minimumSize: WidgetStatePropertyAll(Size(0, 52)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(inherit: true, color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
              ),
            ),
            child: Text(submitting ? 'RESETTING...' : 'RESET'),
          ),
        ),
      ),
    );
  }
}