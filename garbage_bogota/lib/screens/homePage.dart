import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:garbage_bogota/util/globals.dart';
import 'package:garbage_bogota/model/vehicleroute.dart';
import 'package:garbage_bogota/screens/routemap.dart';

final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  final String jwt;
  final Map<String, dynamic> payload;
  HomePage(this.jwt, this.payload);

  factory HomePage.fromBase64(String jwt) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  String datosJsonPeticion = "need to fetch data";
  bool visibilityListView = false;
  var lstRoutes = List<VehicleRoute>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Bogota Garbage Collection"),
          backgroundColor: Colors.green,
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      onPressed: () => _selectDate(context), // Refer step 3
                      child: Text(
                        'Select date',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.lightGreen[300],
                    ),
                  ],
                ),
                RaisedButton(
                  onPressed: () => searchRoutes(), // Refer step 3
                  child: Text(
                    'Search Routes',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                    child: Visibility(
                  visible: visibilityListView,
                  child: ListView.builder(
                      itemCount: lstRoutes.length,
                      itemBuilder: (context, index) {
                        /*return Text('informacion de ruta' +
                            lstRoutes[index].id.toString());*/
                        return Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  getColor(lstRoutes[index].lastIndex),
                              child: Text(this.lstRoutes[index].id.toString()),
                            ),
                            title: Text('Route Information: ' +
                                lstRoutes[index].id.toString()),
                            subtitle: Text('Estimated Time: ' +
                                lstRoutes[index].duration.toString() +
                                ' Stops: ' +
                                lstRoutes[index].steps.length.toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RouteMap(this.lstRoutes[index])),
                              );
                            },
                          ),
                        );
                      }),
                )),
                Visibility(
                  visible: !visibilityListView,
                  child: Expanded(
                    child: Text(
                      datosJsonPeticion,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )),
      );

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<bool> searchRoutes() async {
    String stringDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    String token = await storage.read(key: "jwt");
    if (stringDate != null) {
      var response = await http.get(
        Globals.urlApi + Globals.endPoinRutas + '/' + stringDate,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
      );
      var cuerpoPeticion = jsonDecode(response.body);
      if (cuerpoPeticion is Map<String, dynamic> &&
          cuerpoPeticion.containsKey('mensaje')) {
        setState(() {
          datosJsonPeticion = cuerpoPeticion['mensaje'];
        });
      } else {
        var lstRoutesAux = jsonDecode(response.body) as List;
        lstRoutes = lstRoutesAux.map((route) {
          return VehicleRoute.fromJson(route);
        }).toList();
        lstRoutes.map((route) => route.lastIndex = 0);
        setState(() {
          visibilityListView = true;
        });
      }
      return true;
    } else {
      return false;
    }
  }

  Color getColor(int index) {
    Color dinColor = Colors.blue;
    if (index == null) return Colors.blue;
    if (index == 0) return dinColor = Colors.yellow;
    if (index > int.parse('95')) dinColor = Colors.green;
    if (index > int.parse('0')) dinColor = Colors.blue;
    return dinColor;
  }
}
