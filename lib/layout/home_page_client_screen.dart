import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/layout/cubit/states.dart';
import 'package:map/modules/auth/login_screen.dart';
import 'package:map/shared/components/components.dart';
import 'package:map/shared/local/cache_helper.dart';
import '../modules/order_car_screen.dart';
import '../shared/components/constants.dart';
import 'cubit/cubit.dart';

class HomePageClientScreen extends StatelessWidget {
  TextStyle style = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = MapCubit.get(context);
          return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(driverId)
                  .snapshots(),
              builder: (context, snapshot) {
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  drawer: Drawer(
                    child: Container(
                      color: Colors.white,
                      width: 150,
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cubit.userModel!= null ? cubit.userModel!.name! : '',
                            ),
                            TextButton(
                                onPressed: () {
                                  uId = null;
                                  client = null;
                                  CacheHelper.removeData('uId');
                                  CacheHelper.removeData('client');
                                  navigateAndFinish(context, LoginScreen());
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      'Logout',
                                      style: style,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  appBar: AppBar(
                    title: const Text('Leaflet Map'),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                  ),
                  body: cubit.userModel != null &&
                          cubit.position != null &&
                          state is! GetUserDateLoadingState &&
                      snapshot.connectionState.name == 'active'
                      ? Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                  center: LatLng(cubit.position!.latitude,
                                      cubit.position!.longitude),
                                  zoom: 14.0,
                              ),
                              layers: [
                                TileLayerOptions(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                  attributionBuilder: (_) {
                                    return const Text(
                                        "© OpenStreetMap contributors");
                                  },
                                ),
                                MarkerLayerOptions(
                                  markers: [
                                    if(snapshot.data!.data() != null)
                                      if(!snapshot.data!['isStarted'])
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: LatLng(cubit.position!.latitude,
                                          cubit.position!.longitude),
                                      builder: (ctx) => const Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if(snapshot.data!.data() != null)
                                      if(snapshot.data!['isStarted'])
                                        Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: LatLng(snapshot.data!['driverLat'],snapshot.data!['driverLng']),
                                      builder: (ctx) => const Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    if(snapshot.data!.data() !=null)
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: LatLng(snapshot.data!['lat'],snapshot.data!['lng']),
                                        builder: (ctx) => const Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                                PolylineLayerOptions(
                                  polylines: [
                                    if (snapshot.data!.data()!=null)
                                      if (snapshot.data!['isSelected'] &&
                                          !snapshot.data!['inClient'])
                                        Polyline(points: [
                                          LatLng(cubit.position!.latitude,
                                              cubit.position!.longitude),
                                          LatLng(snapshot.data!['driverLat'],
                                              snapshot.data!['driverLng'])
                                        ], strokeWidth: 4, color: Colors.red),
                                    if (snapshot.data!.data()!=null)
                                      if (snapshot.data!['isStarted'])
                                        Polyline(points: [
                                          LatLng(snapshot.data!['clientLat'],snapshot.data!['clientLng']),
                                          LatLng(snapshot.data!['lat'],
                                              snapshot.data!['lng'])
                                        ], strokeWidth: 4, color: Colors.blue),

                                  ],
                                ),
                              ],
                            ),
                            if(snapshot.data!.data() ==null)
                              Padding(
                                padding: const EdgeInsetsDirectional.all(40),
                                child: defaultButton(
                                  text: 'Order Car Now',
                                  function: () {
                                    navigateTo(context, OrderCarScreen());
                                  },
                                ),
                              ),
                            if(snapshot.data!.data() !=null)
                              if (snapshot.data!['inClient']&&!snapshot.data!['isStarted'])
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const  Card(
                                        child:  Text(
                                          'Your Driver is Ready',
                                          style: TextStyle(
                                            fontSize: 25
                                          ),
                                        ),
                                      ),
                                     const SizedBox(height: 15,),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: defaultButton(
                                              text: 'Cancel order',
                                              color: Colors.red,
                                              function: () {
                                                cubit.cancelOrder();
                                              },
                                            ),
                                          ),
                                         const SizedBox(width: 15,),
                                          Expanded(
                                            child: defaultButton(
                                              text: 'Start Travel',
                                              function: () {
                                                cubit.startOrder();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            if(snapshot.data!.data() != null)
                              if( !snapshot.data!['inClient'])
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        Card(
                                        child:  Text(
                                          snapshot.data!['isSelected']! ? 'Your driver come to you' : 'Your driver not agree yet',
                                          style:const TextStyle(
                                              fontSize: 25
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      defaultButton(
                                        text: 'Cancel order',
                                        color: Colors.red,
                                        function: () {
                                          cubit.cancelOrder();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            if(snapshot.data!.data() != null)
                              if(snapshot.data!['driverLat'] == snapshot.data!['lat'])
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Card(
                                        child:  Text(
                                         'Order is End' ,
                                          style: TextStyle(
                                              fontSize: 25
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      defaultButton(
                                        text: 'End Order and  Check Out' ,
                                        color: Colors.red,
                                        function: () {
                                          cubit.cancelOrder();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                );
              });
        });
  }
}
