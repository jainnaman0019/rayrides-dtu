// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get loginTitle => 'लॉगिन';

  @override
  String get enterPhone => 'अपना फ़ोन नंबर दर्ज करें';

  @override
  String get findRide => 'सवारी ढूंढें';

  @override
  String get selectDriver => 'ड्राइवर चुनें';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get otpDescription => 'हम इस मोबाइल नंबर पर आपको एक वन टाइम पासवर्ड भेजेंगे';

  @override
  String get send => 'भेजें';

  @override
  String get mobileNumberPlaceholder => 'मोबाइल नंबर';

  @override
  String get enterOtp => 'OTP दर्ज करें';

  @override
  String get otpSentTo => 'हमने एक सत्यापन कोड भेजा है';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get didntReceiveCode => 'कोड नहीं मिला?';

  @override
  String get resend => 'पुनः भेजें';

  @override
  String get otpSent => 'OTP भेजा गया!';

  @override
  String get enterFourDigitOtp => 'कृपया 4-अंकीय OTP दर्ज करें';

  @override
  String get invalidOtp => 'अवैध OTP';

  @override
  String get mobileVerificationDone => 'मोबाइल सत्यापन\nसफलतापूर्वक पूरा हुआ';
}
