import 'dart:convert';

class Paso {
  int idStep;
  String type;
  List<double> location;
  List<int> load;
  int arrival;
  int duration;
  int id;
  int job;

  Paso({
    this.idStep,
    this.type,
    this.location,
    this.load,
    this.arrival,
    this.duration,
    this.id,
    this.job,
  });

  String toJson() {
    Map<String, dynamic> step = {
      'idStep': this.idStep,
      'type': this.type,
      'location': this.location,
      'load': this.load,
      'arrival': this.arrival,
      'duration': this.duration,
      'id': this.id,
      'job': this.job,
    };

    return jsonEncode(step);
  }

  factory Paso.fromJson(Map<String, dynamic> json) {
    return Paso(
      idStep: json['idStep'],
      type: json['type'],
      location: json['location'].cast<double>(),
      load: json['load'].cast<int>(),
      arrival: json['arrival'],
      duration: json['duration'],
      id: json['id'],
      job: json['job'],
    );
  }
}
