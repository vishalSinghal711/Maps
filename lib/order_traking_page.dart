import 'dart:async';
import 'dart:collection';
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

  List<LatLng> kajsbd = [
    new LatLng(28.7020, 77.0789),
    new LatLng(29.7020, 78.0789),
    new LatLng(30.7020, 79.0789),
    new LatLng(31.7020, 80.0789),
    new LatLng(32.7020, 81.0789),
    new LatLng(33.7020, 82.0789),
  ];

  LatLng sourceLocation = LatLng(28.55, 77.2667);
  LatLng destination = LatLng(33.7020, 82.0789);
  int sleectedmarker = 0;

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
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );

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
    sourceLocation = kajsbd[sleectedmarker];
    destination = kajsbd[sleectedmarker + 1];
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
              onTap: () {
                setState(() {

                  if (result.points.isNotEmpty) {
                    result.points.forEach(
                      (PointLatLng pt) => {
                        polylineCoordinate.clear(),
                      },
                    );
                  } 

                  sleectedmarker++;
                  if (sleectedmarker >= 5) {
                    sleectedmarker = 0;
                    sourceLocation = kajsbd[sleectedmarker];
                    destination = kajsbd[sleectedmarker + 1];
                  } else {
                    sourceLocation = kajsbd[sleectedmarker-1];
                    destination = kajsbd[sleectedmarker];
                  }
                  
                  getPolyPoints();
                  // List<PointLatLng> lst = [
                  //   PointLatLng(
                  //       sourceLocation.latitude, sourceLocation.longitude),
                  //   PointLatLng(destination.latitude, destination.longitude)
                  // ];
                  // result.points = lst;

                  // if (result.points.isNotEmpty) {
                  //   result.points.forEach(
                  //     (PointLatLng pt) => {
                  //       polylineCoordinate.add(
                  //         LatLng(pt.latitude, pt.longitude),
                  //       ),
                  //     },
                  //   );
                  // }



                  //             result = await polylinePoints.getRouteBetweenCoordinates(
                  //   google_api_key,
                  //   PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
                  //   PointLatLng(destination.latitude, destination.longitude),
                  // );
                });
              },
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
                  target:
                      LatLng(sourceLocation.latitude, sourceLocation.longitude),
                  zoom: 10,
                ),
                polylines: {
                  Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinate,
                      color: Colors.black,
                      width: 6),
                },
                markers: {
                  Marker(
                    markerId: MarkerId("source"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: sourceLocation,
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: destination,
                  ),

                  // const Marker(
                  //   markerId: const MarkerId("destination1"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: kajsbd[0],
                  // ),
                  // const Marker(
                  //   markerId: MarkerId("destination2"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: kajsbd[1],
                  // ),
                  // const Marker(
                  //   markerId: MarkerId("destination3"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: kajsbd[2],
                  // ),
                  // const Marker(
                  //   markerId: MarkerId("destination4"),
                  //   icon: BitmapDescriptor.defaultMarker,
                  //   position: kajsbd[3],
                  // ),
                },
              ),
            ),
    );
  }
}
