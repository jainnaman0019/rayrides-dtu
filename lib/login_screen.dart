import 'package:flutter/material.dart';
import 'package:flutter_ride_app/otp_verification_screen.dart';
import 'package:flutter_ride_app/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phonenumber = TextEditingController();
  final void Function(Locale) setLocale;

  LoginScreen({required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: Text(loc.loginTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () => setLocale(Locale('en')),
            child: Text('English'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => setLocale(Locale('hi')),
            child: Text('हिन्दी'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.createAccount,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.smartphone, size: 40, color: Colors.grey[600]),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 24,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.message, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        loc.enterPhone,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        loc.otpDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: phonenumber,
                        decoration: InputDecoration(
                          hintText: loc.mobileNumberPlaceholder,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (phonenumber.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtpVerificationScreen(phoneNumber: phonenumber.text),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF7043),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            loc.send,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
