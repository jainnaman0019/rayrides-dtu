import 'dart:async';
import 'dart:math';
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
  List<LatLng> routePoints = [];
  List<LatLng> completedRoute = [];

  int currentPointIndex = 0;
  double segmentProgress = 0.0; 
  late LatLng currentDriverLocation;
  late LatLng driverStartLocation; 
  late Timer moveTimer;
  late Timer etaTimer;
  int remainingETA = 60;
  bool rideComplete = false;

  final MapController _mapController = MapController();
  
  static const double movementSpeed = 0.03; 
  static const Duration movementInterval = Duration(milliseconds: 150);

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
    
    
    driverStartLocation = LatLng(
      userLocation!.latitude + 0.012, 
      userLocation!.longitude + 0.015
    );
    
    
    routePoints = _generateRouteToUser(driverStartLocation, userLocation!);

    setState(() {
      currentDriverLocation = driverStartLocation;
      completedRoute.add(driverStartLocation);
    });

    moveTimer = Timer.periodic(movementInterval, (_) => moveDriverAlongRoute());
    etaTimer = Timer.periodic(Duration(seconds: 1), (_) => refreshETA());
  }

  List<LatLng> _generateRouteToUser(LatLng driverStart, LatLng userDestination) {
    List<LatLng> points = [];
    
    
    points.add(driverStart);
    
    
    List<LatLng> waypoints = _createWaypointsToDestination(driverStart, userDestination);
    
    
    points.addAll(waypoints);
    
   
    points.add(userDestination);
    return points;
  }

  List<LatLng> _createWaypointsToDestination(LatLng start, LatLng destination) {
    List<LatLng> waypoints = [];
    
    
    double latDiff = destination.latitude - start.latitude;
    double lngDiff = destination.longitude - start.longitude;
    
    
    int numWaypoints = 4; 
    
    for (int i = 1; i <= numWaypoints; i++) {
      double progress = i / (numWaypoints + 1.0); 
      
      
      double lat = start.latitude + (latDiff * progress);
      double lng = start.longitude + (lngDiff * progress);
      
      
      double deviation = 0.001; 
      if (i % 2 == 0) {
        lat += deviation;
      } else {
        lng += deviation;
      }
      
      waypoints.add(LatLng(lat, lng));
    }
    
    return waypoints;
  }

  List<LatLng> _generateCurvedSegment(LatLng prev, LatLng current, LatLng next) {
    List<LatLng> points = [];
    int segments = 8; 
    
    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      
      
      double lat = _quadraticBezier(prev.latitude, current.latitude, next.latitude, t);
      double lng = _quadraticBezier(prev.longitude, current.longitude, next.longitude, t);
      
     
      double noise = (Random().nextDouble() - 0.5) * 0.0001;
      lat += noise;
      lng += noise;
      
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }

  double _quadraticBezier(double p0, double p1, double p2, double t) {
    return pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + pow(t, 2) * p2;
  }

  void moveDriverAlongRoute() {
    if (currentPointIndex >= routePoints.length - 1) {
      completeRide();
      return;
    }

    setState(() {
      segmentProgress += movementSpeed;
      
      if (segmentProgress >= 1.0) {
       
        completedRoute.add(routePoints[currentPointIndex + 1]);
        
        segmentProgress = 0.0;
        currentPointIndex++;
        
        if (currentPointIndex >= routePoints.length - 1) {
         
          currentDriverLocation = userLocation!;
          return;
        }
      }
      
     
      LatLng startPoint = routePoints[currentPointIndex];
      LatLng endPoint = routePoints[currentPointIndex + 1];
      
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
    setState(() {
      rideComplete = true;
    
      currentDriverLocation = userLocation!;
    });
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
      appBar: AppBar(
        title: Text("Track Ride"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userLocation!,
                    initialZoom: 14,
                    minZoom: 10,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    
                   
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: Colors.blue,
                          strokeWidth: 6,
                          
                        ),
                      ],
                    ),
                    
                   
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: completedRoute,
                          color:Colors.grey.withOpacity(0.5),
                           
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                    
                    
                    if (currentPointIndex < routePoints.length - 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              routePoints[currentPointIndex],
                              currentDriverLocation,
                            ],
                            color: Colors.blue,
                            strokeWidth: 6,
                          ),
                        ],
                      ),
                    
                    MarkerLayer(
                      markers: [
                       
                        Marker(
                          point: userLocation!,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        
                      
                        Marker(
                          point: currentDriverLocation,
                          width: 50,
                          height: 50,
                          child: AnimatedContainer(
                            duration: movementInterval,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
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
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: rideComplete
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 48),
                                SizedBox(height: 12),
                                Text("Driver Arrived!", 
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                                SizedBox(height: 8),
                                Text("${widget.driver.name} has reached your location",
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text("Done", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.person, color: Colors.white, size: 30),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.driver.name, 
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Text(widget.driver.vehicle,
                                              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text("Coming to You", 
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.access_time, color: Colors.blue, size: 24),
                                      SizedBox(width: 8),
                                      Text("Arriving in ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                      Text(formatETA(remainingETA), 
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                
               
                Positioned(
                  top: 100,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _mapController.move(userLocation!, 15);
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
              ],
            ),
    );
  }
}