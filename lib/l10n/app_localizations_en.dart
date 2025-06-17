// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get findRide => 'Find Ride';

  @override
  String get selectDriver => 'Select a Driver';

  @override
  String get createAccount => 'Create Account';

  @override
  String get otpDescription => 'We will send you a one time password on this mobile number';

  @override
  String get send => 'Send';

  @override
  String get mobileNumberPlaceholder => 'Mobile Number';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get otpSentTo => 'We have sent a verification code to';

  @override
  String get verify => 'Verify';

  @override
  String get didntReceiveCode => 'Didn\'t receive code?';

  @override
  String get resend => 'Resend';

  @override
  String get otpSent => 'OTP Sent!';

  @override
  String get enterFourDigitOtp => 'Please enter the 4-digit OTP';

  @override
  String get invalidOtp => 'Invalid OTP';

  @override
  String get mobileVerificationDone => 'Mobile verification has\nsuccessfully done';
}
