
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'driver_model.dart';

class RideTrackingScreen extends StatefulWidget {
  final Driver driver;

  RideTrackingScreen({required this.driver});

  @override
  _RideTrackingScreenState createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  LatLng? userLocation;
  List<LatLng> driverPath = [];

  int currentSegment = 0;
  double segmentProgress = 0.0; 
  late LatLng currentDriverLocation;
  late Timer moveTimer;
  late Timer etaTimer;
  int remainingETA = 60;
  bool rideComplete = false;

  final MapController _mapController = MapController();
  
  
  static const double movementSpeed = 0.02; 
  static const Duration movementInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initLocationAndRide();
  }

  Future<void> _initLocationAndRide() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    userLocation = LatLng(position.latitude, position.longitude);
    
    
    driverPath = [
      LatLng(position.latitude + 0.008, position.longitude + 0.008),
      LatLng(position.latitude + 0.007, position.longitude + 0.006),
      LatLng(position.latitude + 0.005, position.longitude + 0.005),
      LatLng(position.latitude + 0.004, position.longitude + 0.003),
      LatLng(position.latitude + 0.003, position.longitude + 0.003),
      LatLng(position.latitude + 0.002, position.longitude + 0.002),
      LatLng(position.latitude + 0.0015, position.longitude + 0.0015),
      LatLng(position.latitude + 0.001, position.longitude + 0.001),
      LatLng(position.latitude, position.longitude),
    ];

    setState(() {
      currentDriverLocation = driverPath[currentSegment];
    });

    
    moveTimer = Timer.periodic(movementInterval, (_) => moveDriverSmooth());
    etaTimer = Timer.periodic(Duration(seconds: 1), (_) => refreshETA());
  }

  void moveDriverSmooth() {
    if (currentSegment >= driverPath.length - 1) {
      completeRide();
      return;
    }

    setState(() {
      segmentProgress += movementSpeed;
      
      if (segmentProgress >= 1.0) {
        
        segmentProgress = 0.0;
        currentSegment++;
        
        if (currentSegment >= driverPath.length - 1) {
          currentDriverLocation = driverPath.last;
          return;
        }
      }
      
      
      LatLng startPoint = driverPath[currentSegment];
      LatLng endPoint = driverPath[currentSegment + 1];
      
      double lat = startPoint.latitude + 
          (endPoint.latitude - startPoint.latitude) * segmentProgress;
      double lng = startPoint.longitude + 
          (endPoint.longitude - startPoint.longitude) * segmentProgress;
          
      currentDriverLocation = LatLng(lat, lng);
    });
  }

  void refreshETA() {
    if (remainingETA > 0) {
      setState(() => remainingETA -= 1);
    } else {
      etaTimer.cancel();
    }
  }

  void completeRide() {
    moveTimer.cancel();
    etaTimer.cancel();
    setState(() => rideComplete = true);
  }

  @override
  void dispose() {
    if (moveTimer.isActive) moveTimer.cancel();
    if (etaTimer.isActive) etaTimer.cancel();
    super.dispose();
  }

 
  String formatETA(int seconds) {
    if (seconds >= 60) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return "${minutes}m ${remainingSeconds}s";
    }
    return "${seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Track Ride")),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userLocation!,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_on, size: 40, color: Colors.green),
                        ),
                        Marker(
                          point: currentDriverLocation,
                          width: 40,
                          height: 40,
                          child: AnimatedContainer(
                            duration: movementInterval,
                            child: Icon(Icons.directions_car, size: 40, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                       
                        Polyline(
                          points: driverPath,
                          color: Colors.blue.withOpacity(0.3),
                          strokeWidth: 2,
                        ),
                        
                        Polyline(
                          points: [currentDriverLocation, userLocation!],
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: rideComplete
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("✅ Ride Completed", 
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                SizedBox(height: 8),
                                Text("Thank you for riding with ${widget.driver.name}",
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close"),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Driver: ${widget.driver.name}", 
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          Text("Vehicle: ${widget.driver.vehicle}",
                                              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text("ETA", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        Text(formatETA(remainingETA), 
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text("Status", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        Text("En Route", 
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}