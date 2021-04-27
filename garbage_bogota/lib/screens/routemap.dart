import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:garbage_bogota/util/secrets.dart'; // Stores the Google Maps API Key

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:garbage_bogota/model/vehicleroute.dart';
import 'package:garbage_bogota/model/paso.dart';
import 'package:garbage_bogota/components/blurrydialog.dart';

class RouteMap extends StatefulWidget {
  VehicleRoute vehicleRoute;
  RouteMap(this.vehicleRoute);

  @override
  State<RouteMap> createState() => RouteMapState(vehicleRoute);
}

class RouteMapState extends State<RouteMap> {
  VehicleRoute vehicleRoute;
  RouteMapState(this.vehicleRoute);

  CameraPosition _initialLocation = CameraPosition(target: LatLng(4.0, -72.0));
  GoogleMapController mapController;

  List<Paso> lstStepsRoute;

  Position _currentPosition;
  String _currentAddress;

  bool routeStart;
  double progress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    print("calculando distancia");
    Position startCoordinates, destinationCoordinates;
    try {
      // Retrieving placemarks from addresses

      Paso startPlacemark, destinationPlacemark;

      if (routeStart) {
        startPlacemark = lstStepsRoute[0];
        destinationPlacemark = lstStepsRoute[0];
        startCoordinates = Position(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude);

        destinationCoordinates = Position(
            latitude: destinationPlacemark.location[1],
            longitude: destinationPlacemark.location[0]);

        this.vehicleRoute.lastIndex = 0;
        setState(() {
          routeStart = false;
        });
      } else {
        if (this.vehicleRoute.lastIndex < lstStepsRoute.length) {
          startPlacemark = lstStepsRoute[this.vehicleRoute.lastIndex];
          destinationPlacemark = lstStepsRoute[this.vehicleRoute.lastIndex + 1];
          startCoordinates = Position(
              latitude: startPlacemark.location[1],
              longitude: startPlacemark.location[0]);
          destinationCoordinates = Position(
              latitude: destinationPlacemark.location[1],
              longitude: destinationPlacemark.location[0]);
        } else {
          _showDialog(context, "Ruta Completada",
              "Ha completado la ruta calculada para el dia, Muchas gracias");
          this.vehicleRoute.lastIndex = 0;
          setState(() {
            routeStart = true;
          });
        }
      }

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? startCoordinates.latitude
                : destinationCoordinates.latitude;
        double minx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? startCoordinates.longitude
                : destinationCoordinates.longitude;
        double maxy =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? destinationCoordinates.latitude
                : startCoordinates.latitude;
        double maxx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? destinationCoordinates.longitude
                : startCoordinates.longitude;

        _southwestCoordinates = Position(latitude: miny, longitude: minx);
        _northeastCoordinates = Position(latitude: maxy, longitude: maxx);

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    //call to google maps API
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRouteMarkers();
    if (this.vehicleRoute.lastIndex == null) {
      this.vehicleRoute.lastIndex = 0;
      routeStart = true;
    } else {
      routeStart = false;
    }
    progress = (this.vehicleRoute.lastIndex / this.vehicleRoute.steps.length);
  }

  /* _loadRoutesFromJson() async {
    var routesJson =
        await DefaultAssetBundle.of(context).loadString('assets/routes.json');
    var lstAux = jsonDecode(routesJson) as List;
    lstAux = lstAux.map((route) {
      return VehicleRoute.fromJson(route);
    }).toList();
    setState(() {
      lstRoutes = lstAux;
    });
  }*/

  _loadRouteMarkers() {
    lstStepsRoute = this.vehicleRoute.steps;
    markers.clear();
    for (Paso pass in lstStepsRoute) {
      Marker marker = new Marker(
        markerId: MarkerId(pass.id.toString() + pass.idStep.toString()),
        position: LatLng(
          pass.location[1],
          pass.location[0],
        ),
        infoWindow: InfoWindow(
          title: 'Estimated Time: ' + pass.duration.toString() + ' seconds',
          snippet: 'Estimated Load: ' + pass.load[0].toString() + ' litters',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(marker);
    }
  }

  _centerView() async {
    await mapController.getVisibleRegion();

    var left = lstStepsRoute[0].location[1];
    var right = lstStepsRoute[0].location[1];
    var top = lstStepsRoute[0].location[0];
    var bottom = lstStepsRoute[0].location[0];

    lstStepsRoute.forEach((paso) {
      left = min(left, paso.location[1]);
      right = max(right, paso.location[1]);
      top = max(top, paso.location[0]);
      bottom = min(bottom, paso.location[0]);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    mapController.animateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Bogota Garbage Collection'),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        // Create the SelectionButton widget in the next step.
        body: Container(
          height: height,
          width: width,
          child: Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: <Widget>[
                // Map View
                GoogleMap(
                  markers: markers != null ? Set<Marker>.from(markers) : null,
                  initialCameraPosition: _initialLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polylines.values),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _centerView();
                  },
                ),
                // Show zoom buttons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Colors.blue[100], // button color
                            child: InkWell(
                              splashColor: Colors.blue, // inkwell color
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.add),
                              ),
                              onTap: () {
                                mapController.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ClipOval(
                          child: Material(
                            color: Colors.blue[100], // button color
                            child: InkWell(
                              splashColor: Colors.blue, // inkwell color
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.remove),
                              ),
                              onTap: () {
                                mapController.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Show the place input fields & button for
                // showing the route
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        width: width * 0.4,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Route#: ' + this.vehicleRoute.id.toString(),
                                style: TextStyle(fontSize: 20.0),
                              ),
                              SizedBox(height: 10),
                              Visibility(
                                visible: _placeDistance == null ? false : true,
                                child: Text(
                                  'DISTANCE: $_placeDistance km',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.all(15.0),
                                child: new LinearPercentIndicator(
                                  width: width * 0.33,
                                  animation: true,
                                  lineHeight: 20.0,
                                  animationDuration: 2000,
                                  percent:
                                      num.parse(progress.toStringAsFixed(1)),
                                  center: Text(
                                      (progress * 100).toStringAsFixed(1) +
                                          ' %'),
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Colors.lightGreen,
                                ),
                              ),
                              SizedBox(height: 10),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green)),
                                onPressed: () async {
                                  startAddressFocusNode.unfocus();
                                  desrinationAddressFocusNode.unfocus();
                                  setState(() {
                                    if (markers.isNotEmpty) markers.clear();
                                    if (polylines.isNotEmpty) polylines.clear();
                                    if (polylineCoordinates.isNotEmpty)
                                      polylineCoordinates.clear();
                                    _placeDistance = null;
                                  });

                                  _calculateDistance().then((isCalculated) {
                                    this.vehicleRoute.lastIndex =
                                        this.vehicleRoute.lastIndex + 1;
                                    setState(() {
                                      progress = this.vehicleRoute.lastIndex /
                                          lstStepsRoute.length;
                                    });
                                  });
                                },
                                color: Colors.green,
                                textColor: Colors.white,
                                child: Text(
                                  routeStart
                                      ? 'Start Route'.toUpperCase()
                                      : 'Next Container'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green)),
                                onPressed: () {
                                  _showDialog(context, "route",
                                      this.vehicleRoute.id.toString());
                                },
                                color: Colors.green,
                                textColor: Colors.white,
                                child: Text(
                                  'Show Text'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Show current location button
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: ClipOval(
                        child: Material(
                          color: Colors.orange[100], // button color
                          child: InkWell(
                            splashColor: Colors.orange, // inkwell color
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(Icons.my_location),
                            ),
                            onTap: () {
                              mapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      _currentPosition.latitude,
                                      _currentPosition.longitude,
                                    ),
                                    zoom: 18.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _showDialog(BuildContext context, String title, String content) {
    VoidCallback continueCallBack = () => {
          Navigator.of(context).pop(),
          // code on continue comes here
        };
    BlurryDialog alert = BlurryDialog(title, content, continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
