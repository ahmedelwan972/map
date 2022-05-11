
import 'dart:io';
import 'package:geolocator/geolocator.dart';


class LocationHelper{

  static Future<Position> getCurrentLocation ()async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission= await Geolocator.checkPermission();
    if(!isServiceEnabled){
      await Geolocator.openLocationSettings();
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      exit(0);
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

  }
}