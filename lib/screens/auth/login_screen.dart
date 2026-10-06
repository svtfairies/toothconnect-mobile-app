import 'dart:async';
import 'package:flutter/material.dart';
import '../glob/users.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool submitting = false;
  bool emailError = false;
  bool passwordError = false;

  String error = '';

  int loginLockoutSeconds = 0;
  int registerCooldownSeconds = 0;

  Timer? loginTimer;
  Timer? registerTimer;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    loginTimer?.cancel();
    registerTimer?.cancel();
    super.dispose();
  }

  bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value.trim());
  }

  String formatCooldown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void startLoginLockout() {
    loginTimer?.cancel();

    setState(() {
      loginLockoutSeconds = 5 * 60;
    });

    loginTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (loginLockoutSeconds <= 1) {
          timer.cancel();

          setState(() {
            loginLockoutSeconds = 0;
          });

          return;
        }

        setState(() {
          loginLockoutSeconds--;
        });
      },
    );
  }

  void startRegisterCooldown() {
    registerTimer?.cancel();

    setState(() {
      registerCooldownSeconds = 5 * 60;
    });

    registerTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (registerCooldownSeconds <= 1) {
          timer.cancel();

          setState(() {
            registerCooldownSeconds = 0;
          });

          return;
        }

        setState(() {
          registerCooldownSeconds--;
        });
      },
    );
  }

  Future<void> handleLogin() async {
    if (submitting || loginLockoutSeconds > 0) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      error = '';
      emailError = false;
      passwordError = false;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        emailError = true;
        passwordError = true;
        error = 'Email and Password are required.';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        emailError = true;
        error = 'Email is Required.';
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        emailError = true;
        error = 'Please enter a valid email address.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = true;
        error = 'Password is Required.';
      });
      return;
    }

    setState(() {
      submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    final user = AllUsers.userList.cast<Map<String, dynamic>?>().firstWhere(
      (user) => user?['email']?.toString().toLowerCase() == email.toLowerCase() && user?['password']?.toString() == password,
      orElse: () => null,
    );

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        submitting = false;
        error = 'Invalid email or password.';
        emailError = true;
        passwordError = true;
      });
      return;
    }

    AllUsers.currentUser = user;

    setState(() {
      submitting = false;
    });

    Navigator.pushReplacementNamed(context, '/home', arguments: user);
  }

  void goToRegister() {
    if (registerCooldownSeconds > 0) {
      return;
    }

    Navigator.pushNamed(context, '/register');
  }

  void goToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password', arguments: {'prefilledEmail': emailController.text.trim().toLowerCase()});
  }

  @override
  Widget build(BuildContext context) {
    final bool loginLocked = loginLockoutSeconds > 0;
    final bool registerLocked = registerCooldownSeconds > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, top: 28, bottom: 96),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildLogoSection(),
                    buildLoginCard(loginLocked: loginLocked, registerLocked: registerLocked),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogoSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      child: Column(
        children: [
          Image.asset('assets/images/clinic-logo.jpg', width: 135, height: 135, fit: BoxFit.contain),
          const SizedBox(height: 8),
          const Text('ToothConnect', style: TextStyle(inherit: true, fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFB47A00), fontFamily: 'Arial')),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text('Your dental care, connected.', style: TextStyle(inherit: true, fontSize: 13, color: Color(0xFF1F1F1F), fontFamily: 'Arial')),
          ),
          Container(width: 195, height: 2, decoration: BoxDecoration(color: const Color(0xFFC88A11), borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget buildLoginCard({required bool loginLocked, required bool registerLocked}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.86,
      constraints: const BoxConstraints(minHeight: 390),
      padding: const EdgeInsets.only(left: 34, right: 34, top: 20, bottom: 34),
      decoration: const BoxDecoration(
        color: Color(0xFFE4CF88),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('LOGIN', style: TextStyle(inherit: true, fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFFC78300), fontFamily: 'Arial')),
            ),
          ),
          if (registerCooldownSeconds > 0) buildWarningBox(),
          buildLabel('Email', emailError),
          const SizedBox(height: 6),
          buildEmailInput(),
          buildLabel('Password', passwordError),
          const SizedBox(height: 6),
          buildPasswordInput(),
          buildForgotPassword(),
          if (error.isNotEmpty) buildErrorBox(),
          buildLoginButton(loginLocked),
          buildDivider(),
          buildCreateAccount(registerLocked),
        ],
      ),
    );
  }

  Widget buildLabel(String text, bool hasError) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: const TextStyle(inherit: true, fontSize: 18, color: Color(0xFF8B6508), fontWeight: FontWeight.w800, fontFamily: 'Arial')),
    );
  }

  Widget buildEmailInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enabled: !submitting && loginLockoutSeconds <= 0,
        onChanged: (_) {
          if (emailError || error.isNotEmpty) {
            setState(() {
              emailError = false;
              error = '';
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: const TextStyle(inherit: true, fontSize: 15, color: Color(0xFF888888), fontFamily: 'Arial'),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          constraints: const BoxConstraints(minHeight: 46),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: emailError ? const BorderSide(color: Color(0xFFD03939), width: 1) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: emailError ? const BorderSide(color: Color(0xFFD03939), width: 1) : BorderSide.none,
          ),
        ),
        style: const TextStyle(inherit: true, fontSize: 15, color: Color(0xFF2F2F2F), fontFamily: 'Arial'),
      ),
    );
  }

  Widget buildPasswordInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: passwordError ? Border.all(color: const Color(0xFFD03939), width: 1) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: passwordController,
              obscureText: !showPassword,
              textInputAction: TextInputAction.done,
              enabled: !submitting && loginLockoutSeconds <= 0,
              onSubmitted: (_) => handleLogin(),
              onChanged: (_) {
                if (passwordError || error.isNotEmpty) {
                  setState(() {
                    passwordError = false;
                    error = '';
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(inherit: true, fontSize: 15, color: Color(0xFF888888), fontFamily: 'Arial'),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(inherit: true, fontSize: 15, color: Color(0xFF2F2F2F), fontFamily: 'Arial'),
            ),
          ),
          SizedBox(
            height: 46,
            child: TextButton(
              onPressed: submitting || loginLockoutSeconds > 0
                  ? null
                  : () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
              style: ButtonStyle(
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.disabled) ? const Color(0xFFB77C00).withValues(alpha: 0.5) : const Color(0xFFB77C00),
                ),
                textStyle: const WidgetStatePropertyAll(TextStyle(inherit: true, fontSize: 11, color: Color(0xFFB77C00), fontWeight: FontWeight.w900, fontFamily: 'Arial')),
              ),
              child: Text(showPassword ? 'HIDE' : 'SHOW'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        child: TextButton(
          onPressed: submitting ? null : goToForgotPassword,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) => states.contains(WidgetState.disabled) ? const Color(0xFFBF8300).withValues(alpha: 0.5) : const Color(0xFFBF8300),
            ),
            textStyle: const WidgetStatePropertyAll(TextStyle(inherit: true, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Arial')),
          ),
          child: const Text('Forgot Password?'),
        ),
      ),
    );
  }

  Widget buildErrorBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(6)),
      child: Text(error, textAlign: TextAlign.center, style: const TextStyle(inherit: true, color: Color(0xFF9B2C2C), fontSize: 13, fontFamily: 'Arial')),
    );
  }

  Widget buildWarningBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        border: Border.all(color: const Color(0xFFE58A8A)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Too many attempts. Please wait ${formatCooldown(registerCooldownSeconds)}.',
        textAlign: TextAlign.center,
        style: const TextStyle(inherit: true, color: Color(0xFF9B2C2C), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Arial', height: 18 / 13),
      ),
    );
  }

  Widget buildLoginButton(bool loginLocked) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.86,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          child: ElevatedButton(
            onPressed: submitting || loginLocked ? null : handleLogin,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.disabled) ? const Color(0xFFC98904).withValues(alpha: 0.7) : const Color(0xFFC98904),
              ),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 13)),
              minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(inherit: true, color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
              ),
            ),
            child: Text(submitting ? 'SIGNING IN...' : loginLocked ? formatCooldown(loginLockoutSeconds) : 'SIGN IN'),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.2,
      margin: const EdgeInsets.only(top: 28, bottom: 14),
      color: const Color(0xFFB98212),
    );
  }

  Widget buildCreateAccount(bool registerLocked) {
    return Center(
      child: TextButton(
        onPressed: submitting || registerLocked ? null : goToRegister,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 2)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          textStyle: const WidgetStatePropertyAll(TextStyle(inherit: true, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Arial')),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(inherit: true, color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Arial'),
            children: [
              const TextSpan(text: 'Don’t have an account? '),
              TextSpan(
                text: 'Create Account',
                style: TextStyle(
                  inherit: true,
                  color: registerLocked ? const Color(0xFFB77C00).withValues(alpha: 0.45) : const Color(0xFFB77C00),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}