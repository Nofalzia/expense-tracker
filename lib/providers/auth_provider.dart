import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isLoading = true; // Start as true for initial check
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized; // Add this getter
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;
  String? get userName => _user?.displayName;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize auth state
  void _initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get current user immediately
      _user = _authService.currentUser;
      
      // Then listen to changes
      _authService.authStateChanges.listen((User? user) {
        _user = user;
        _isInitialized = true;
        notifyListeners();
      });
      
    } catch (e) {
      print('❌ Auth initialization error: $e');
      _errorMessage = e.toString();
    } finally {
      // Wait a bit before setting isLoading to false
      await Future.delayed(Duration(milliseconds: 500));
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with Firebase
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _user = user; // Update user immediately
        print('✅ Firebase login successful: ${user.email}');
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('❌ Firebase login error: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signup with Firebase
  Future<void> signup(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email, 
        password, 
        name,
      );
      
      // Create user document in Firestore
      if (user != null) {
        _user = user; // Update user immediately
        await _createUserDocument(user.uid, email, name);
        print('✅ Firebase signup successful: ${user.email}');
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('❌ Firebase signup error: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(String uid, String email, String name) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User document created for: $email');
    } catch (e) {
      print('❌ Error creating user document: $e');
    }
  }

  /// Logout
Future<void> logout() async {
  _isLoading = true;
  notifyListeners();
  
  try {
    await _authService.signOut();
    _user = null;
    
    // ADD THIS: Clear all provider state
    print('✅ User logged out - clearing state');
    
    // Optional: If you're using Firebase Auth, this helps
    await FirebaseAuth.instance.signOut();
    
  } catch (e) {
    _errorMessage = _getErrorMessage(e);
    print('❌ Logout error: $_errorMessage');
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.sendPasswordResetEmail(email);
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      print('❌ Password reset error: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'Email already registered';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';
        default:
          return error.message ?? 'An error occurred';
      }
    }
    return error.toString();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}