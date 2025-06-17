import 'package:flutter/material.dart';
import 'ride_tracking_screen.dart';
import 'driver_model.dart';
import 'package:flutter_ride_app/l10n/app_localizations.dart';

class DriverSelectionScreen extends StatelessWidget {
  final List<Driver> drivers = [
    Driver(name: "Ravi", vehicle: "Swift - DL1234", rating: 4.7, etaMinutes: 3),
    Driver(name: "Amit", vehicle: "WagonR - DL5678", rating: 4.8, etaMinutes: 5),
    Driver(name: "Pooja", vehicle: "Alto - DL9999", rating: 4.5, etaMinutes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.selectDriver)),
      body: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(driver.name),
              subtitle: Text(
                "${driver.vehicle} | ⭐ ${driver.rating} | ETA: ${driver.etaMinutes} min",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RideTrackingScreen(driver: driver),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
