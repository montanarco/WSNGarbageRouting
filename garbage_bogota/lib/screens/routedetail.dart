import 'package:flutter/material.dart';
import 'package:garbage_bogota/model/vehicleroute.dart';

class RouteDetail extends StatefulWidget {
  final VehicleRoute vehicleRoute;
  RouteDetail(this.vehicleRoute);

  @override
  State<StatefulWidget> createState() => RouteDetailState(vehicleRoute);
}

class RouteDetailState extends State {
  VehicleRoute vehicleRoute;
  RouteDetailState(this.vehicleRoute);
  TextEditingController idController = TextEditingController();
  TextEditingController costController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    idController.text = vehicleRoute.id.toString();
    costController.text = vehicleRoute.cost.toString();
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la ruta $vehicleRoute.id'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              controller: idController,
              style: textStyle,
              decoration: InputDecoration(
                  labelText: "Id Ruta",
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
            TextField(
              controller: costController,
              style: textStyle,
              decoration: InputDecoration(
                  labelText: "costo Ruta",
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
            new Expanded(
                child: new ListView.builder(
                    itemCount: vehicleRoute.steps.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return new ListTile(
                        title:
                            Text(vehicleRoute.steps[index].idStep.toString()),
                        subtitle:
                            Text(vehicleRoute.steps[index].location.toString()),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
