import 'dart:async';
import 'package:flutter/material.dart';
import '../../glob/users.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int resendWaitSeconds = 60;
  static const int maxResendAttempts = 3;
  static const int maxOtpVerificationAttempts = 3;
  static const int otpLockRedirectSeconds = 5;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String step = 'email';
  String error = '';

  bool submitting = false;
  bool canResend = false;
  bool otpCodeExhausted = false;

  int resendTimer = resendWaitSeconds;
  int remainingResendAttempts = maxResendAttempts;
  int remainingOtpVerificationAttempts = maxOtpVerificationAttempts;
  int otpRedirectSeconds = 0;

  Timer? resendTimerObject;
  Timer? otpRedirectTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      final prefilledEmail = arguments['prefilledEmail']?.toString() ?? '';

      if (prefilledEmail.isNotEmpty && emailController.text.isEmpty) {
        emailController.text = prefilledEmail;
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    resendTimerObject?.cancel();
    otpRedirectTimer?.cancel();
    super.dispose();
  }

  bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value.trim());
  }

  void startResendTimer() {
    resendTimerObject?.cancel();

    setState(() {
      resendTimer = resendWaitSeconds;
      canResend = false;
    });

    resendTimerObject = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
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
      },
    );
  }

  void startOtpRedirect() {
    otpRedirectTimer?.cancel();

    setState(() {
      otpRedirectSeconds = otpLockRedirectSeconds;
      error = 'Too many incorrect attempts. You will be redirected to the login page in $otpLockRedirectSeconds seconds.';
    });

    otpRedirectTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (otpRedirectSeconds <= 1) {
          timer.cancel();

          setState(() {
            otpRedirectSeconds = 0;
          });

          Future.delayed(
            Duration(milliseconds: 300),
            () {
              if (!mounted) {
                return;
              }

              Navigator.pushReplacementNamed(
                context,
                '/login',
                arguments: {
                  'prefilledEmail': emailController.text.trim().toLowerCase(),
                  'passwordResetOtpLocked': true,
                  'passwordResetCooldownSeconds': 5 * 60,
                  'passwordResetCooldownMessage': 'Too many failed attempts. Please wait 5 minutes before trying to change your password again.',
                },
              );
            },
          );

          return;
        }

        setState(() {
          otpRedirectSeconds--;
          error = 'Too many incorrect attempts. You will be redirected to the login page in $otpRedirectSeconds seconds.';
        });
      },
    );
  }

  void handleBack() {
    if (submitting || otpRedirectSeconds > 0) {
      return;
    }

    setState(() {
      error = '';
    });

    if (step == 'email') {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      step = 'email';
      otpController.clear();
      otpRedirectSeconds = 0;
      remainingOtpVerificationAttempts = maxOtpVerificationAttempts;
      otpCodeExhausted = false;
      canResend = false;
      resendTimer = resendWaitSeconds;
    });

    resendTimerObject?.cancel();
  }

  Future<void> handleSendOtp() async {
    if (submitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
    });

    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        error = 'Please enter your email.';
      });

      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        error = 'Please enter a valid email address.';
      });

      return;
    }

    final userExists = AllUsers.userList.any((user) => user['email']?.toString().toLowerCase() == email.toLowerCase());

    if (!userExists) {
      setState(() {
        error = 'No registered account found with this email.';
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
      otpController.clear();
      remainingResendAttempts = maxResendAttempts;
      remainingOtpVerificationAttempts = maxOtpVerificationAttempts;
      otpCodeExhausted = false;
      otpRedirectSeconds = 0;
      error = '';
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
      remainingOtpVerificationAttempts = maxOtpVerificationAttempts;
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

    startOtpRedirect();
  }

  Future<void> handleVerifyOtp() async {
    if (submitting || otpCodeExhausted || otpRedirectSeconds > 0) {
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

    setState(() {
      submitting = false;
    });

    if (code != '123456') {
      handleInvalidOtpAttempt();
      return;
    }

    Navigator.pushNamed(context, '/reset-password', arguments: {'email': emailController.text.trim().toLowerCase(), 'code': code});
  }

  String getTitle() {
    if (step == 'email') {
      return 'FORGOT PASSWORD';
    }

    return 'ENTER THE CODE';
  }

  String getSubtitle() {
    if (step == 'email') {
      return 'Please enter your registered email to receive your One-Time Password (OTP) to reset your password.';
    }

    return 'A 6-digit code was sent to your email address.';
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
                buildCard(),
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
          Text('ToothConnect', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFB47A00), fontFamily: 'Arial')),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text('Your dental care, connected.', style: TextStyle(fontSize: 13, color: Color(0xFF1F1F1F), fontFamily: 'Arial')),
          ),
          Container(width: 195, height: 2, decoration: BoxDecoration(color: Color(0xFFC88A11), borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget buildCard() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 360),
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
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    getTitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC78300), fontFamily: 'Arial'),
                  ),
                ),
                SizedBox(height: 14),
                Center(
                  child: Text(
                    getSubtitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF1F1F1F), fontWeight: FontWeight.w700, fontFamily: 'Arial', height: 18 / 12),
                  ),
                ),
                SizedBox(height: 20),
                Container(width: double.infinity, height: 1.2, margin: EdgeInsets.only(bottom: 18), color: Color(0xFFB98212)),
                if (step == 'email') buildEmailStep(),
                if (step == 'otp') buildOtpStep(),
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
          onPressed: submitting || otpRedirectSeconds > 0 ? null : handleBack,
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

  Widget buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Email'),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enabled: !submitting,
            onChanged: (_) {
              if (error.isNotEmpty) {
                setState(() {
                  error = '';
                });
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter your email',
              hintStyle: TextStyle(inherit: true, color: Color(0xFFB8B8B8), fontSize: 15, fontFamily: 'Arial'),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            ),
            style: TextStyle(inherit: true, fontSize: 15, color: Color(0xFF2F2F2F), fontFamily: 'Arial'),
          ),
        ),
        if (error.isNotEmpty) buildErrorBox(),
        buildButton(text: submitting ? 'SENDING OTP...' : 'SEND OTP', onPressed: submitting ? null : handleSendOtp),
      ],
    );
  }

  Widget buildOtpStep() {
    final bool resendDisabled = !canResend || submitting || remainingResendAttempts <= 0;

    final String resendText = remainingResendAttempts <= 0
        ? 'Resend Limit Reached'
        : canResend
            ? 'Resend Code ($remainingResendAttempts)'
            : 'Resend in ${resendTimer}s ($remainingResendAttempts)';

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
            enabled: !submitting && !otpCodeExhausted && otpRedirectSeconds <= 0,
            onChanged: (_) {
              if (error.isNotEmpty) {
                setState(() {
                  error = '';
                });
              }
            },
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              hintText: '000000',
              hintStyle: TextStyle(inherit: true, color: Color(0xFFB8B8B8), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Arial'),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            ),
            style: TextStyle(inherit: true, fontSize: 24, color: Color(0xFF2F2F2F), fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Arial'),
          ),
        ),
        Container(
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
                    TextStyle(inherit: true, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
                  ),
                ),
                child: Text(resendText),
              ),
            ],
          ),
        ),
        if (error.isNotEmpty) buildErrorBox(),
        buildButton(text: submitting ? 'VERIFYING...' : 'VERIFY OTP', onPressed: submitting || otpCodeExhausted || otpRedirectSeconds > 0 ? null : handleVerifyOtp),
      ],
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: TextStyle(inherit: true, fontSize: 19, color: Color(0xFFB77C00), fontWeight: FontWeight.w900, fontFamily: 'Arial'),
      ),
    );
  }

  Widget buildErrorBox() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12, bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        error,
        textAlign: TextAlign.center,
        style: TextStyle(inherit: true, color: Color(0xFF9B2C2C), fontSize: 13, fontFamily: 'Arial'),
      ),
    );
  }

  Widget buildButton({required String text, required VoidCallback? onPressed}) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.86,
        child: Container(
          margin: EdgeInsets.only(top: 26),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) => states.contains(WidgetState.disabled) ? Color(0xFFC98904).withValues(alpha: 0.7) : Color(0xFFC98904)),
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
}