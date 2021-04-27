import 'dart:convert';

import 'package:garbage_bogota/model/paso.dart';

class VehicleRoute {
  int id;
  int vehicle;
  int cost;
  int lastIndex;
  List<int> delivery;
  List<int> amount;
  List<int> pickup;
  int service;
  int duration;
  int waitingTime;
  List<Paso> steps;
  String createdOn;

  VehicleRoute(
      {this.id,
      this.vehicle,
      this.cost,
      this.delivery,
      this.amount,
      this.pickup,
      this.service,
      this.duration,
      this.waitingTime,
      this.steps,
      this.createdOn});

  String toJson() {
    Map<String, dynamic> vehicleRouteMap = {
      'id': this.id,
      'vehicle': this.vehicle,
      'cost': this.cost,
      'delivery': this.delivery,
      'amount': this.amount,
      'pickup': this.pickup,
      'service': this.service,
      'duration': this.duration,
      'waiting_time': this.waitingTime,
      'steps': this.steps,
      'createdOn': this.createdOn,
    };

    return jsonEncode(vehicleRouteMap);
  }

  factory VehicleRoute.fromJson(Map<String, dynamic> json) {
    var stepObjsJson = json['steps'] as List;
    return VehicleRoute(
        id: json['id'],
        vehicle: json['vehicle'],
        cost: json['cost'],
        delivery: json['delivery'].cast<int>(),
        amount: json['amount'].cast<int>(),
        pickup: json['pickup'].cast<int>(),
        service: json['service'],
        duration: json['duration'],
        waitingTime: json['waiting_time'],
        steps: stepObjsJson.map((paso) => Paso.fromJson(paso)).toList(),
        createdOn: json['createdOn']);
  }
}
