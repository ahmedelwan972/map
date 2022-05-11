import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/layout/cubit/states.dart';
import 'package:map/models/all_users_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map/shared/local/cache_helper.dart';
import '../../models/RouteModel.dart';
import '../../models/user_model.dart';
import '../../shared/components/constants.dart';
import '../../shared/location_helper/geolocator.dart';

class MapCubit extends Cubit<MapStates> {
  MapCubit() : super(InitState());
  static MapCubit get(context) => BlocProvider.of(context);

  ///////////////AUTH

  bool isPassword = true;

  bool isPasswordS = true;

  bool isPasswordSC = true;

  bool isDriver = false;



  void emitS() {
    emit(ChangeVisibilityState());
  }

  void changeIsPassword() {
    isPassword = !isPassword;
    emit(ChangeVisibilityState());
  }

  void changeIsPasswordS() {
    isPasswordS = !isPasswordS;
    emit(ChangeVisibilityState());
  }

  void changeIsPasswordSC() {
    isPasswordSC = !isPasswordSC;
    emit(ChangeVisibilityState());
  }

  void register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(RegisterLoadingState());
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      userData(
        phone: phone,
        name: name,
        email: email,
        uId: value.user!.uid,
      );
    }).catchError((e) {
      print(e.toString());
      emit(RegisterErrorState(e.toString()));
    });
  }

  userData({
    required String email,
    required String phone,
    required String name,
    required String uId,
  }) async {
    emit(UserDataLoadingState());
    UserModel model = UserModel(
      email: email,
      name: name,
      phone: phone,
      lat: 26.549999,
      long: 31.700001,
      uId: uId,
      client: isDriver,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
          CacheHelper.saveData(key: 'client', value: isDriver);
          client = isDriver;
      emit(UserDataSuccessState(uId));
    }).catchError((e) {
      print(e.toString());
      emit(UserDataErrorState());
    });
  }

  login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoadingState());
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      emit(LoginSuccessState(value.user!.uid));
    }).catchError((e) {
      print(e.toString());
      emit(LoginErrorState(e.toString()));
    });
  }

  Position? position;
  Future<void> getCurrentLocation() async {
    emit(GetCurrentLocationLoadingState());
    await LocationHelper.getCurrentLocation();
    position = await Geolocator.getLastKnownPosition().whenComplete(() {
      emit(GetCurrentLocationState());
    });
  }

  UserModel? userModel;
  Future<void>getUserData() async {
      if(uId != null){
        emit(GetUserDateLoadingState());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uId)
            .get()
            .then((value) {
          userModel = UserModel.fromJson(value.data()!);
          CacheHelper.saveData(key: 'client', value: userModel!.client!);
          client = userModel!.client!;
          emit(GetUserDateSuccessState());
        }).catchError((e) {
          print(e.toString());
          emit(GetUserDateErrorState(e.toString()));
        });
      }
  }

  //////////////////////////////////

  List<AllUsersModel> allUsersModel = [];

  Future<void>getAllDriver() async {
    allUsersModel = [];
    emit(GetAllUserDateLoadingState());
    await FirebaseFirestore.instance.collection('users').get().then((value) {
      value.docs.forEach((element) {
        allUsersModel.add(AllUsersModel.fromJson(element.data()));
        getDistanceBetween(
          endLatitude: element.get('lat'),
          endLongitude:element.get('long') ,
        );
        emit(GetAllUserDateSuccessState());
      });
    }).catchError((e) {
      print(e.toString());
      emit(GetAllUserDateErrorState(e.toString()));
    });
  }
  
  
  List<int> distance =[];
  
  getDistanceBetween({
    required double endLatitude,
    required double endLongitude,
}){
    distance.add(Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      endLatitude,
      endLongitude,
    ).toInt(),);
  }



  String currentCity='';
  String currentCountry='';
  String distanceCity='';
  String distanceCountry='';
  Future<void> getCurrentAddress() async {
    if(position != null){
      List<Placemark> place =
      await placemarkFromCoordinates(position!.latitude, position!.longitude);
      Placemark placeMark = place[0];
      currentCity = placeMark.locality!;
      currentCountry = placeMark.country!;
      emit(GetCurrentLocationState());
    }
  }

  Future<void> getDistanceAddress() async {
    if(distantion != null){
      List<Placemark> place =
      await placemarkFromCoordinates(distantion!.point.latitude, distantion!.point.longitude);
      Placemark placeMark = place[0];
      distanceCity = placeMark.locality!;
      distanceCountry = placeMark.country!;
      emit(GetCurrentLocationState());
     // Future.delayed(Duration(minutes: 1)).then((value) => null);
    }
  }

  Marker? distantion;

  chooseDistance({required LatLng pos}){
    distantion= Marker(
      width: 80.0,
      height: 80.0,
      point: pos,
      builder: (ctx) =>
      const Icon(
        Icons.location_on,
        size: 40,
        color: Colors.red,
      ),
    );
    emit(ChooseLocationState());
  }



  driverIsSelected({
    required String driver,
    required double driverLat,
    required double driveLng,
}){
    emit(SelectedDriverLoadingState());
    FirebaseFirestore.instance
        .collection('orders')
        .doc(driver)
        .set({
      'from': ' $currentCountry , $currentCity',
      'to': '$distanceCountry , $distanceCity',
      'driverId':driver,
      'driverLat':driverLat,
      'driverLng':driveLng,
      'isSelected':false,
      'isStarted':false,
      'inClient':false,
      'name': userModel!.name,
      'clientLat': position!.latitude,
      'clientLng': position!.longitude,
      'lat': distantion!.point.latitude,
      'lng': distantion!.point.longitude,
    }).then((value) {
      CacheHelper.saveData(key: 'driverId', value: driver)
          .then((value) {
            driverId = driver;
            emit(SelectedDriverSuccessState());
          }).catchError((e){
            emit(SelectedDriverErrorState());
          });
    }).catchError((e){
      emit(SelectedDriverErrorState());
    });
  }


  orderAgreed(){
    FirebaseFirestore.instance
        .collection('orders')
        .doc(uId)
        .update({
      'isSelected' : true,
    });
    emit(StartGoSuccessState());
  }


  driverInClient(){
    FirebaseFirestore.instance
        .collection('orders')
        .doc(uId)
        .update({
      'inClient' : true,
    });
    emit(StartOrderSuccessState());
  }

  startOrder(){
    FirebaseFirestore.instance
        .collection('orders')
        .doc(driverId)
        .update({
      'isStarted' : true,
    });
    emit(StartOrderSuccessState());
  }

  cancelOrder(){
    FirebaseFirestore.instance
        .collection('orders')
        .doc(driverId)
        .delete();
    emit(CancelOrderSuccessState());
  }


  updateDistanceToClient(){
    Timer(const Duration(seconds: 10), ()async{
      getCurrentLocation();
     await FirebaseFirestore.instance
          .collection('orders')
          .doc(uId)
          .update({
        'driverLat':position!.latitude,
        'driverLng':position!.longitude,
      }).then((value) {
       print('hi');
       emit(UpdateLocationToClientSuccessState());
     }).catchError((e){
       print('this error $e');
     });
    });
  }

  updateDistanceToLocation(){
    Timer(const Duration(seconds: 10), ()async{
      getCurrentLocation();
     await FirebaseFirestore.instance
          .collection('orders')
          .doc(uId)
          .update({
       'clientLat':position!.latitude,
       'clientLng':position!.longitude,
      }).then((value) {
       emit(UpdateLocationSuccessState());
     }).catchError((e){
        print('here error $e');
     });
    });
  }

  RouteModel? routeModel;
  getDirections()async{
    // print('${position!.longitude},${position!.latitude};${distantion!.point.longitude},${distantion!.point.latitude}');
     await Dio().get('https://api.mapbox.com/directions/v5/mapbox/driving/${position!.longitude},${position!.latitude};${distantion!.point.longitude},${distantion!.point.latitude}?geometries=geojson&access_token=pk.eyJ1IjoiYWhtZWRlbHdhbiIsImEiOiJjbDFyNGlkcGkwYWhkM2pwYTJkMDBoYWs4In0.F36siyNJRimDd1Cx8SnIpQ')
        .then((value) {
      routeModel = RouteModel.fromJson(value.data);
      emit(SelectDirectionSuccessState());
    }).catchError((e){
      print('this is error  $e');
      emit(SelectDirectionErrorState());
    });

  }


}






