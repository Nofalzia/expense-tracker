import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';

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
  bool _showPassword = false;

  static const Color accentColor = Color(0xFF4A6CF7);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    // Listen to auth state changes directly for debugging
    if (authProvider.isLoggedIn) {
      print('🎯 LoginScreen: User is logged in! Redirecting to dashboard...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28.0, vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ICON
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 38,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // MAIN HEADING
                      Text(
                        _isLogin ? "Welcome Back" : "Create Your Account",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                          fontFamily: "Poppins",
                        ),
                      ),

                      const SizedBox(height: 10),

                      // SUBTEXT
                      Text(
                        _isLogin
                            ? "Sign in to manage your expenses."
                            : "Start tracking your finances effortlessly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Poppins",
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // FORM
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!_isLogin) ...[
                              _buildInputField(
                                controller: _nameController,
                                label: "Full Name",
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    value!.isEmpty ? "Enter your full name" : null,
                              ),
                              const SizedBox(height: 18),
                            ],

                            _buildInputField(
                              controller: _emailController,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!value.contains("@")) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildInputField(
                              controller: _passwordController,
                              label: "Password",
                              icon: Icons.lock_outline,
                              obscure: !_showPassword,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
                                child: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 6) {
                                  return "Minimum 6 characters";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // MAIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);

                                          try {
                                            if (_isLogin) {
                                              print('🔄 Attempting login...');
                                              await authProvider.login(
                                                _emailController.text.trim(),
                                                _passwordController.text.trim(),
                                              );
                                              
                                              // Check if login was successful
                                              await Future.delayed(Duration(milliseconds: 500));
                                              
                                              if (authProvider.isLoggedIn) {
                                                print('✅ Login successful! User: ${authProvider.userEmail}');
                                                
                                                // Navigate to dashboard
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                                                  );
                                                });
                                              } else {
                                                print('❌ Login failed: User not set in provider');
                                                _showErrorSnackbar(context, 'Login failed. Please try again.');
                                              }
                                            } else {
                                              await authProvider.signup(
                                                _emailController.text.trim(),
                                                _passwordController.text.trim(),
                                                _nameController.text.trim(),
                                              );
                                              _showSuccessFeedback();
                                              
                                              // After successful signup, switch to login mode
                                              setState(() {
                                                _isLogin = true;
                                                _nameController.clear();
                                              });
                                            }
                                          } catch (e) {
                                            print('❌ Login error: $e');
                                            _showErrorSnackbar(context, e.toString());
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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
                                    : Text(
                                        _isLogin ? "Sign In" : "Create Account",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // TOGGLE LOGIN/SIGNUP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account? "
                                : "Already have an account?",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Poppins",
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _nameController.clear();
                              });
                            },
                            child: Text(
                              _isLogin ? "Sign Up" : "Sign In",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins",
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_isLogin) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context),
                          child: const Text(
                            "Forgot your password?",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: size.height * 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // INPUT FIELD
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
      cursorColor: accentColor,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.6),
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }

  // SUCCESS FEEDBACK
  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Account created successfully!',
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Reset Password",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Enter your email to receive a reset link.",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: "Poppins")),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Reset link sent!", style: TextStyle(fontFamily: "Poppins")),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Send Link", style: TextStyle(fontFamily: "Poppins")),
          ),
        ],
      ),
    );
  }
}