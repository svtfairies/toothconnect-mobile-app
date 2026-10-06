import 'dart:async';
import 'package:flutter/material.dart';
import '../glob/users.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final List<Map<String, String>> branches = [
    {'id': '1', 'name': 'Main Branch', 'address': 'Makati City'},
    {'id': '2', 'name': 'Quezon Branch', 'address': 'Quezon City'},
    {'id': '3', 'name': 'Las Pinas Branch', 'address': 'Las Pinas City'},
  ];

  String? branchId;
  String step = 'form';
  String error = '';

  bool submitting = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  bool nameTouched = false;
  bool emailTouched = false;
  bool branchTouched = false;
  bool passwordTouched = false;
  bool confirmPasswordTouched = false;
  bool hasSubmittedForm = false;

  bool canResend = false;
  bool otpCodeExhausted = false;

  int resendTimer = 60;
  int remainingResendAttempts = 3;
  int remainingOtpVerificationAttempts = 3;

  Timer? resendTimerObject;
  Timer? otpRedirectTimer;

  int? otpRedirectSeconds;

  void saveRegisteredUser() {
    final selectedBranch = branches.firstWhere(
      (branch) => branch['id'] == branchId,
    );

    AllUsers.userList.add({
      'id': 'USR${DateTime.now().millisecondsSinceEpoch}',
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'branchId': branchId,
      'branchName': selectedBranch['name'],
      'branchAddress': selectedBranch['address'],
      'role': 'Patient',
      'status': 'active',
      'verified': true,
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    resendTimerObject?.cancel();
    otpRedirectTimer?.cancel();
    super.dispose();
  }

  bool isValidFullName(String value) {
    final cleanName = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final words = cleanName.split(' ');

    if (cleanName.length < 3) {
      return false;
    }

    if (words.length < 2) {
      return false;
    }

    return words.every((word) => word.length >= 2);
  }

  bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value.trim());
  }

  String getPasswordError(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    if (!RegExp(r'^[A-Za-z\d]+$').hasMatch(value)) {
      return 'Password must not contain spaces or special characters.';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one letter and one number.';
    }

    return '';
  }

  Map<String, String> getFormFieldErrors() {
    final Map<String, String> errors = {};

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      errors['name'] = 'This field is required.';
    } else if (!isValidFullName(name)) {
      errors['name'] = 'Please enter your first and last name.';
    }

    if (email.isEmpty) {
      errors['email'] = 'This field is required.';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address.';
    }

    if (branchId == null) {
      errors['branch'] = 'Please pick your preferred branch.';
    }

    if (password.isEmpty) {
      errors['password'] = 'This field is required.';
    } else {
      final passwordError = getPasswordError(password);

      if (passwordError.isNotEmpty) {
        errors['password'] = passwordError;
      }
    }

    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'This field is required.';
    } else {
      final confirmPasswordError = getPasswordError(confirmPassword);

      if (confirmPasswordError.isNotEmpty) {
        errors['confirmPassword'] = confirmPasswordError;
      } else if (password != confirmPassword) {
        errors['confirmPassword'] = 'Passwords do not match.';
      }
    }

    return errors;
  }

  bool shouldShowFieldError(bool touched) {
    return touched || hasSubmittedForm;
  }

  void startResendTimer() {
    resendTimerObject?.cancel();

    setState(() {
      resendTimer = 60;
      canResend = false;
    });

    resendTimerObject = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (resendTimer <= 1) {
        timer.cancel();

        setState(() {
          resendTimer = 0;
          canResend = true;
        });

        return;
      }

      setState(() {
        resendTimer--;
      });
    });
  }

  void handleInvalidOtpAttempt() {
    final remaining = remainingOtpVerificationAttempts - 1;

    setState(() {
      remainingOtpVerificationAttempts = remaining < 0 ? 0 : remaining;
    });

    if (remaining > 0) {
      setState(() {
        error = 'Invalid code. You have $remaining OTP verification attempts remaining.';
      });

      return;
    }

    setState(() {
      otpController.clear();
      otpCodeExhausted = true;
      error = 'OTP verification failed. Please request a new code.';
    });
  }

  void startOtpRedirect() {
    otpRedirectTimer?.cancel();

    setState(() {
      otpRedirectSeconds = 5;
      error = 'Too many incorrect attempts. You will be redirected to the login page in 5 seconds.';
    });

    otpRedirectTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (otpRedirectSeconds == null || otpRedirectSeconds! <= 1) {
        timer.cancel();

        setState(() {
          otpRedirectSeconds = 0;
        });

        Future.delayed(Duration(milliseconds: 300), () {
          if (!mounted) {
            return;
          }

          Navigator.pushReplacementNamed(context, '/login');
        });

        return;
      }

      setState(() {
        otpRedirectSeconds = otpRedirectSeconds! - 1;
        error = 'Too many incorrect attempts. You will be redirected to the login page in ${otpRedirectSeconds!} seconds.';
      });
    });
  }

  void handleBackToForm() {
    setState(() {
      step = 'form';
      error = '';
      otpController.clear();
      otpRedirectSeconds = null;
      otpCodeExhausted = false;
    });

    otpRedirectTimer?.cancel();
  }

  Future<void> handleStart() async {
    if (submitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
      hasSubmittedForm = true;
    });

    final fieldErrors = getFormFieldErrors();

    final firstError = fieldErrors['name'] ?? fieldErrors['email'] ?? fieldErrors['branch'] ?? fieldErrors['password'] ?? fieldErrors['confirmPassword'] ?? '';

    if (firstError.isNotEmpty) {
      setState(() {
        error = firstError;
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
      step = 'otp';
      error = '';
      otpController.clear();
      remainingOtpVerificationAttempts = 3;
      remainingResendAttempts = 3;
      otpCodeExhausted = false;
      otpRedirectSeconds = null;
    });

    startResendTimer();
  }

  Future<void> handleResendOtp() async {
    if (submitting || !canResend || remainingResendAttempts <= 0) {
      return;
    }

    setState(() {
      submitting = true;
      error = '';
    });

    await Future.delayed(Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    final nextAttempts = remainingResendAttempts - 1;

    setState(() {
      submitting = false;
      remainingResendAttempts = nextAttempts;
      otpController.clear();
      remainingOtpVerificationAttempts = 3;
      otpCodeExhausted = false;
    });

    if (nextAttempts <= 0) {
      setState(() {
        canResend = false;
        resendTimer = 0;
      });

      return;
    }

    startResendTimer();
  }

  Future<void> handleVerify() async {
    if (submitting || otpCodeExhausted || otpRedirectSeconds != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
    });

    final code = otpController.text.trim();

    if (code.isEmpty) {
      setState(() {
        error = 'Please enter the OTP code.';
      });

      return;
    }

    if (code.length != 6) {
      setState(() {
        error = 'OTP code must be 6 digits.';
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

    if (code != '123456') {
      setState(() {
        submitting = false;
      });

      handleInvalidOtpAttempt();

      if (remainingOtpVerificationAttempts <= 1) {
        startOtpRedirect();
      }

      return;
    }

    setState(() {
      submitting = false;
    });

    saveRegisteredUser();

    Navigator.pushReplacementNamed(context, '/login');
  }

  void goToLogin() {
    if (submitting) {
      return;
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final fieldErrors = step == 'form' ? getFormFieldErrors() : <String, String>{};

    final nameHasError = fieldErrors['name'] != null && shouldShowFieldError(nameTouched);
    final emailHasError = fieldErrors['email'] != null && shouldShowFieldError(emailTouched);
    final branchHasError = fieldErrors['branch'] != null && hasSubmittedForm;
    final passwordHasError = fieldErrors['password'] != null && shouldShowFieldError(passwordTouched);
    final confirmPasswordHasError = fieldErrors['confirmPassword'] != null && shouldShowFieldError(confirmPasswordTouched);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 140),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLogoSection(),
                buildRegisterCard(
                  nameHasError: nameHasError,
                  emailHasError: emailHasError,
                  branchHasError: branchHasError,
                  passwordHasError: passwordHasError,
                  confirmPasswordHasError: confirmPasswordHasError,
                ),
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

  Widget buildRegisterCard({required bool nameHasError, required bool emailHasError, required bool branchHasError, required bool passwordHasError, required bool confirmPasswordHasError}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 420),
      padding: EdgeInsets.only(left: 34, right: 34, top: 22, bottom: 34),
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
          if (step == 'otp') buildBackButton(),
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    step == 'form' ? 'CREATE ACCOUNT' : 'ENTER THE CODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(inherit: true, fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC78300), fontFamily: 'Arial'),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    step == 'form' ? 'Sign up to book appointments' : 'A 6-digit code was sent to your email address.',
                    textAlign: TextAlign.center,
                    style: TextStyle(inherit: true, fontSize: 12, color: Color(0xFF1F1F1F), fontWeight: FontWeight.w700, fontFamily: 'Arial'),
                  ),
                ),
                SizedBox(height: 18),
                if (step == 'otp') Container(width: double.infinity, height: 1.2, margin: EdgeInsets.only(bottom: 20), color: Color(0xFFB98212)),
                if (step == 'form')
                  buildFormStep(
                    nameHasError: nameHasError,
                    emailHasError: emailHasError,
                    branchHasError: branchHasError,
                    passwordHasError: passwordHasError,
                    confirmPasswordHasError: confirmPasswordHasError,
                  )
                else
                  buildOtpStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackButton() {
    return Positioned(
      top: -6,
      left: -6,
      child: SizedBox(
        width: 40,
        height: 40,
        child: ElevatedButton(
          onPressed: submitting ? null : handleBackToForm,
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

  Widget buildFormStep({required bool nameHasError, required bool emailHasError, required bool branchHasError, required bool passwordHasError, required bool confirmPasswordHasError}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Full Name', nameHasError),
        buildTextInput(
          controller: nameController,
          hint: 'e.g. Mary Ortega',
          hasError: nameHasError,
          keyboardType: TextInputType.name,
          onChanged: (value) {
            setState(() {
              nameTouched = true;
              error = '';
            });
          },
        ),
        buildLabel('Email', emailHasError),
        buildTextInput(
          controller: emailController,
          hint: 'e.g. mary@gmail.com',
          hasError: emailHasError,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              emailTouched = true;
              error = '';
            });
          },
        ),
        buildLabel('Home Branch', branchHasError),
        buildBranchPicker(branchHasError),
        buildLabel('Password', passwordHasError),
        buildPasswordInput(
          controller: passwordController,
          hint: 'Letters and numbers only',
          showPassword: showPassword,
          hasError: passwordHasError,
          onChanged: (value) {
            setState(() {
              passwordTouched = true;
              error = '';
            });
          },
          onToggle: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
        ),
        buildLabel('Confirm Password', confirmPasswordHasError),
        buildPasswordInput(
          controller: confirmPasswordController,
          hint: 'Re-enter password',
          showPassword: showConfirmPassword,
          hasError: confirmPasswordHasError,
          onChanged: (value) {
            setState(() {
              confirmPasswordTouched = true;
              error = '';
            });
          },
          onToggle: () {
            setState(() {
              showConfirmPassword = !showConfirmPassword;
            });
          },
        ),
        if (error.isNotEmpty) buildErrorBox(error),
        buildMainButton(text: submitting ? 'SENDING OTP...' : 'SEND OTP', onPressed: submitting ? null : handleStart),
        buildDivider(),
        buildSignInLink(),
      ],
    );
  }

  Widget buildLabel(String text, bool hasError) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        hasError ? '$text *' : text,
        style: TextStyle(inherit: true, fontSize: 18, color: hasError ? Color(0xFF9B2C2C) : Color(0xFF8B6508), fontWeight: FontWeight.w900, fontFamily: 'Arial'),
      ),
    );
  }

  Widget buildTextInput({required TextEditingController controller, required String hint, required bool hasError, required TextInputType keyboardType, required ValueChanged<String> onChanged}) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !submitting,
        onChanged: onChanged,
        onTap: () {
          setState(() {
            error = '';
          });
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(inherit: true, fontSize: 15, color: Color(0xFFB8B8B8), fontFamily: 'Arial'),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: hasError ? BorderSide(color: Color(0xFFC62828), width: 1.5) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: hasError ? BorderSide(color: Color(0xFFC62828), width: 1.5) : BorderSide.none,
          ),
        ),
        style: TextStyle(inherit: true, fontSize: 15, color: Color(0xFF2F2F2F), fontFamily: 'Arial'),
      ),
    );
  }

  Widget buildPasswordInput({required TextEditingController controller, required String hint, required bool showPassword, required bool hasError, required ValueChanged<String> onChanged, required VoidCallback onToggle}) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: hasError ? Border.all(color: Color(0xFFC62828), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !showPassword,
              enabled: !submitting,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(inherit: true, fontSize: 15, color: Color(0xFFB8B8B8), fontFamily: 'Arial'),
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

  Widget buildBranchPicker(bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: branches.map((branch) {
            final bool isActive = branchId == branch['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  branchId = branch['id'];
                  branchTouched = true;
                  error = '';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                margin: EdgeInsets.only(right: 6, bottom: 8),
                decoration: BoxDecoration(
                  color: isActive ? Color(0xFFC98904) : Colors.white,
                  border: Border.all(color: Color(0xFFC98904), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch['name'] ?? '', style: TextStyle(inherit: true, fontSize: 13, color: isActive ? Colors.white : Color(0xFFB77C00), fontWeight: isActive ? FontWeight.w900 : FontWeight.w800, fontFamily: 'Arial')),
                    SizedBox(height: 2),
                    Text(branch['address'] ?? '', style: TextStyle(inherit: true, fontSize: 11, color: isActive ? Colors.white : Color(0xFFB77C00), fontWeight: FontWeight.w500, fontFamily: 'Arial')),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (hasError) Padding(padding: EdgeInsets.only(top: 2), child: Text('Please pick your preferred branch.', style: TextStyle(inherit: true, fontSize: 12, color: Color(0xFF9B2C2C), fontFamily: 'Arial'))),
      ],
    );
  }

  Widget buildErrorBox(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12, bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(6)),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(inherit: true, color: Color(0xFF9B2C2C), fontSize: 13, fontFamily: 'Arial')),
    );
  }

  Widget buildMainButton({required String text, required VoidCallback? onPressed}) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.86,
        child: Container(
          margin: EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.disabled) ? Color(0xFFC98904).withValues(alpha: 0.7) : Color(0xFFC98904),
              ),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              elevation: WidgetStatePropertyAll(0),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 13)),
              minimumSize: WidgetStatePropertyAll(Size(0, 52)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              textStyle: WidgetStatePropertyAll(
                TextStyle(inherit: true, color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
              ),
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Container(width: double.infinity, height: 1.2, margin: EdgeInsets.only(top: 28, bottom: 14), color: Color(0xFFB98212));
  }

  Widget buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: submitting ? null : goToLogin,
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 2)),
          minimumSize: WidgetStatePropertyAll(Size(0, 0)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: WidgetStatePropertyAll(Colors.white),
          textStyle: WidgetStatePropertyAll(
            TextStyle(inherit: true, color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Arial'),
          ),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(inherit: true, color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Arial'),
            children: [
              TextSpan(text: 'Already have an account? '),
              TextSpan(text: 'Sign In', style: TextStyle(inherit: true, color: Color(0xFFB77C00), fontWeight: FontWeight.w900, fontFamily: 'Arial')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            enabled: !submitting && !otpCodeExhausted && otpRedirectSeconds == null,
            onChanged: (_) {
              setState(() {
                error = '';
              });
            },
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              hintText: '000000',
              hintStyle: TextStyle(inherit: true, color: Color(0xFFB8B8B8), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Arial'),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            ),
            style: TextStyle(inherit: true, fontSize: 24, color: Color(0xFF2F2F2F), fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Arial'),
          ),
        ),
        buildResendRow(),
        if (error.isNotEmpty) buildErrorBox(otpRedirectSeconds != null ? 'Too many incorrect attempts. You will be redirected to the login page in $otpRedirectSeconds seconds.' : error),
        buildMainButton(
          text: submitting ? 'VERIFYING...' : 'VERIFY OTP',
          onPressed: submitting || otpCodeExhausted || otpRedirectSeconds != null ? null : handleVerify,
        ),
      ],
    );
  }

  Widget buildResendRow() {
    final bool resendDisabled = !canResend || submitting || remainingResendAttempts <= 0;

    String resendText;

    if (remainingResendAttempts <= 0) {
      resendText = 'Resend Limit Reached';
    } else if (canResend) {
      resendText = 'Resend Code ($remainingResendAttempts)';
    } else {
      resendText = 'Resend in ${resendTimer}s ($remainingResendAttempts)';
    }

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Didn’t receive a code?', style: TextStyle(inherit: true, color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Arial')),
          TextButton(
            onPressed: resendDisabled ? null : handleResendOtp,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
              minimumSize: WidgetStatePropertyAll(Size(0, 0)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.disabled) ? Color(0xFFB77C00).withValues(alpha: 0.5) : Color(0xFFB77C00),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(inherit: true, color: Color(0xFFB77C00), fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
              ),
            ),
            child: Text(resendText),
          ),
        ],
      ),
    );
  }
}