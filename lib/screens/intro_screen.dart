import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF4A6CF7); // Your blue (74,108,247)

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/untitled.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [

                  const Spacer(flex: 2),

                  // ===== TEXT SECTION (LEFT ALIGNED) =====
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        Text(
                          '\n\n\n\n\n\n\n\n\n\nEasy for\nBeginners,\nEfficient For All',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Subheading
                        Text(
                          'Effortless Expense Tracking For Everyone.\n'
                          'Discover How Simple Analytics Can Make\nFinancial Understanding Easy.',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ===== BUTTONS =====
                  Row(
                    children: [
                      // LOGIN button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'LOGIN',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // CREATE ACCOUNT button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: accentColor,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: accentColor,
                            ),
                            child: Text(
                              'CREATE ACCOUNT',
                              style: GoogleFonts.poppins(
                                fontSize: 12.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
