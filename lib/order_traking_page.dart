import 'dart:async';
import 'package:location/location.dart';

import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng destination = LatLng(28.6922, 77.1507);

  //data from api - waypoints
  List<PolylineWayPoint> waypoints = [
    PolylineWayPoint(location: 'A-11,Budh-Vihar,Phase-1,Delhi-110086',),
    PolylineWayPoint(location: 'Tarun Enclave'),
    PolylineWayPoint(
        location:
            'A-4 Block,Baba Ramdev Marg,Shiva Enclave,Paschim-Vihar,New Delhi, Delhi 110063'),
  ];
  //final path
  List<LatLng> polylineCoordinate = [];
  LocationData? currentLocation;

// on app start
  void getCurrentLocation() async {
    Location location = Location();
    final cLocation = await location.getLocation();
    setState(() {
      currentLocation = cLocation;
    });
  }

  late PolylineResult result;
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      result = await polylinePoints.getRouteBetweenCoordinates(
          google_api_key,
          PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          PointLatLng(destination.latitude, destination.longitude),
          wayPoints: waypoints);

      if (result.points.isNotEmpty) {
        print('IIIIIIIIIIIIII');
        result.points.forEach(
          (PointLatLng pt) => {
            polylineCoordinate.add(
              LatLng(pt.latitude, pt.longitude),
            ),
          },
        );
        setState(() {});
      } else {
        print('DDDDDDDDD');
      }
    } catch (e) {
      print('Exception is  ${e}');
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                getPolyPoints();
              },
              child: Text(
                'Reload',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: currentLocation == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Center(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 5,
                ),
                polylines: {
                  Polyline(
                      polylineId: PolylineId("distance"),
                      points: polylineCoordinate,
                      color: Colors.black,
                      width: 6),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("source"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                  ),
                  Marker(
                    markerId: const MarkerId("destination"),
                    position: destination,
                  ),
                  ...waypoints.asMap().entries.map((dest) {
                    int destnum = dest.key;
                    PolylineWayPoint desti = dest.value;
                    return Marker(
                      markerId: MarkerId(destnum.toString()),
                      icon: BitmapDescriptor.defaultMarker,
                    );
                  },),
                },
              ),
            ),
    );
  }
}
