import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/utils/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showPassword = false; // For password visibility toggle

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top spacing - Robinhood uses generous padding
                        SizedBox(height: size.height * 0.08),

                        /// ICON with subtle animation
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32), // Increased spacing

                        /// HEADING with improved typography
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isLogin
                                ? 'Welcome Back!'
                                : 'Create Account',
                            key: ValueKey(_isLogin),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SUBTITLE with smooth transition
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isLogin
                                ? 'Sign in to manage your expenses'
                                : 'Start tracking your finances effortlessly',
                            key: ValueKey('subtitle_$_isLogin'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40), // More whitespace

                        /// FORM with improved input fields
                        Form(
                          key: _formKey,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axis: Axis.vertical,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey(_isLogin),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!_isLogin) ...[
                                  _buildInputField(
                                    controller: _nameController,
                                    label: "Full Name",
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                _buildInputField(
                                  controller: _emailController,
                                  label: "Email Address",
                                  icon: Icons.email_outlined,
                                  keyboard: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                _buildInputField(
                                  controller: _passwordController,
                                  label: "Password",
                                  icon: Icons.lock_outline,
                                  obscure: !_showPassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    child: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey.shade500,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'At least 6 characters required';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 32),

                                /// PRIMARY BUTTON with improved styling
                                SizedBox(
                                  width: double.infinity,
                                  height: 58, // Slightly taller
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            // Add haptic feedback
                                            // HapticFeedback.lightImpact(); // Uncomment if you have haptics package

                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() => _isLoading = true);

                                              try {
                                                if (_isLogin) {
                                                  await authProvider.login(
                                                    _emailController.text
                                                        .trim(),
                                                    _passwordController.text
                                                        .trim(),
                                                  );
                                                } else {
                                                  await authProvider.signup(
                                                    _emailController.text
                                                        .trim(),
                                                    _passwordController.text
                                                        .trim(),
                                                    _nameController.text.trim(),
                                                  );
                                                  // Show success feedback
                                                  _showSuccessFeedback();
                                                }
                                              } catch (e) {
                                                // Enhanced error feedback
                                                _showErrorSnackbar(
                                                    context, e.toString());
                                              } finally {
                                                setState(
                                                    () => _isLoading = false);
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                      shadowColor:
                                          AppColors.primary.withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : AnimatedSwitcher(
                                            duration:
                                                const Duration(milliseconds: 200),
                                            child: Text(
                                              _isLogin
                                                  ? 'Sign In'
                                                  : 'Create Account',
                                              key: ValueKey(_isLogin),
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// TOGGLE SECTION with improved interaction
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin
                                    ? "Don't have an account? "
                                    : "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Clear form fields when toggling
                                  if (_isLogin) {
                                    _nameController.clear();
                                  }
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _isLogin ? "Sign Up" : "Sign In",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_isLogin) ...[
                          const SizedBox(height: 20),
                          // Forgot password with better visibility
                          GestureDetector(
                            onTap: () {
                              _showForgotPasswordDialog(context);
                            },
                            child: Text(
                              "Forgot your password?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],

                        // Bottom spacing
                        SizedBox(height: size.height * 0.05),
                      ],
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

  /// ----------------------------------------------------------------------
  /// ENHANCED INPUT FIELD WITH ROBINHOOD-STYLE
  /// ----------------------------------------------------------------------
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// ----------------------------------------------------------------------
  /// ENHANCED FEEDBACK METHODS
  /// ----------------------------------------------------------------------
  void _showSuccessFeedback() {
    // In a real app, you might use a package like confetti or show a success animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Text(
              'Account created successfully!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade50,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset link sent to your email!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}