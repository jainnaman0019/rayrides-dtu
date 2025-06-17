import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_ride_app/l10n/app_localizations.dart';
import 'package:flutter_ride_app/map_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  OtpVerificationScreen({required this.phoneNumber});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in otpControllers) c.dispose();
    for (var f in otpFocusNodes) f.dispose();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      FocusScope.of(context).unfocus(); // close keyboard
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    String otp = otpControllers.map((c) => c.text).join();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MapScreen()));
  }

  void _resendOtp() {
    for (var c in otpControllers) c.clear();
    otpFocusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.resend),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
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
                        loc.verify,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 32),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(16)),
                        child: Icon(Icons.celebration, size: 40, color: Colors.orange),
                      ),
                      SizedBox(height: 32),
                      Text(
                        loc.mobileVerificationDone,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          children: [
                            TextSpan(text: '${loc.otpSent} '),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 50,
                            height: 60,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: otpFocusNodes[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                counterText: '',
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (value) => _onOtpChanged(value, index),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _resendOtp,
                        child: Text(
                          loc.resend,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF7043),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Text(loc.verify, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
