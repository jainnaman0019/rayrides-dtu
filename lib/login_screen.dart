import 'package:flutter/material.dart';
import 'package:flutter_ride_app/map_screen.dart';
import 'package:flutter_ride_app/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phonenumber = TextEditingController();
  final void Function(Locale) setLocale;

  LoginScreen({required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
  title: Text(loc.loginTitle),
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
    SizedBox(width: 8),
  ],
),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: phonenumber,
                decoration: InputDecoration(
                  labelText: loc.enterPhone,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MapScreen()));
              },
              child: Text(loc.findRide),
            ),
          ],
        ),
      ),
    );
  }
}
