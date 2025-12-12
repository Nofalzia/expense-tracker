import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/intro_screen.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/screens/add_transaction_screen.dart';
import 'package:expense_tracker/screens/transaction_list_screen.dart';
import 'package:expense_tracker/screens/analytics_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: FirebaseConfig.apiKey,
          authDomain: FirebaseConfig.authDomain,
          projectId: FirebaseConfig.projectId,
          storageBucket: FirebaseConfig.storageBucket,
          messagingSenderId: FirebaseConfig.messagingSenderId,
          appId: FirebaseConfig.appId,
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<TransactionProvider>(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primaryColor: Color(0xFF4A6CF7),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/intro': (context) => IntroScreen(),
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/add-transaction': (context) => AddTransactionScreen(),
          '/transactions': (context) => TransactionListScreen(),
          '/analytics': (context) => AnalyticsScreen(),
          '/profile': (context) => ProfileScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Show loading screen while checking auth
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Auth is initialized, check if user is logged in
    if (authProvider.isLoggedIn) {
      print('🎯 User is logged in: ${authProvider.userEmail}');
      return DashboardScreen();
    } else {
      print('🎯 User is not logged in, showing intro');
      return IntroScreen();
    }
  }
}