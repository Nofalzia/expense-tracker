import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _userEmail;
  String? _userName;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  /// SIMULATED LOGIN - Accepts any email/password for testing
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // For testing: Accept ANY email/password
    // In real app, this would call Firebase Auth
    
    _userEmail = email;
    _userName = _extractNameFromEmail(email);
    _isLoggedIn = true;
    _isLoading = false;
    
    print('✅ Login successful: $email');
    notifyListeners();
  }

  /// SIMULATED SIGNUP - Accepts any data for testing
  Future<void> signup(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // For testing: Accept ANY data
    // In real app, this would call Firebase Auth
    
    _userEmail = email;
    _userName = name;
    _isLoggedIn = true;
    _isLoading = false;
    
    print('✅ Signup successful: $name ($email)');
    notifyListeners();
  }

  /// Extract name from email (for demo purposes)
  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return 'User';
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    print('🚪 User logged out');
    notifyListeners();
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}