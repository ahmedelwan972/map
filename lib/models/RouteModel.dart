import 'package:latlong2/latlong.dart';

class RouteModel {
  List<Routes>? routes;
  List<Waypoints>? waypoints;
  String? code;
  String? uuid;


  RouteModel.fromJson(Map<String, dynamic> json) {
    if (json['routes'] != null) {
      routes = <Routes>[];
      json['routes'].forEach((v) { routes!.add( Routes.fromJson(v)); });
    }
    if (json['waypoints'] != null) {
      waypoints = <Waypoints>[];
      json['waypoints'].forEach((v) { waypoints!.add(Waypoints.fromJson(v)); });
    }
    code = json['code'];
    uuid = json['uuid'];
  }

}

class Routes {
  Geometry? geometry;
  String? weightName;
  double? weight;
  double? duration;
  double? distance;


  Routes.fromJson(Map<String, dynamic> json) {
    geometry = json['geometry'] != null ?  Geometry.fromJson(json['geometry']) : null;
    weightName = json['weight_name'];
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
  }

}

class Geometry {
  List<dynamic>? coordinates;
  String? type;

  Geometry.fromJson(Map<String, dynamic> json) {
    if (json['coordinates'] != null) {
      coordinates = <dynamic>[];
      json['coordinates'].forEach((v) { coordinates!.add(v); });
    }
    type = json['type'];
  }

}





class Waypoints {
  double? distance;
  String? name;
  List<double>? location;


  Waypoints.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    name = json['name'];
    location = json['location'].cast<double>();
  }

}
