import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/layout/cubit/states.dart';
import 'package:map/modules/auth/login_screen.dart';
import 'package:map/shared/components/components.dart';
import 'package:map/shared/local/cache_helper.dart';
import '../shared/components/constants.dart';
import 'cubit/cubit.dart';

class HomePageScreen extends StatelessWidget {
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
                  .doc(uId)
                  .snapshots(),
              builder: (context, snapshot) {
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  drawer: Drawer(
                    child: Container(
                      color: Colors.white,
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                cubit.userModel!.name!
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
                  body: cubit.userModel != null && cubit.position != null &&state is! GetUserDateLoadingState&&
                      snapshot.connectionState.name == 'active'
                      ? Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                center: LatLng(cubit.position!.latitude,
                                    cubit.position!.longitude),
                                zoom: 14.0,
                                onTap: (p,l){
                                  if (snapshot.data != null) {
                                    if (snapshot.data!['isSelected'] &&
                                        !snapshot.data!['inClient']) {
                                      cubit.updateDistanceToClient();
                                    } else if (snapshot.data!['inClient']) {
                                      cubit.updateDistanceToLocation();
                                    }
                                  }
                                },
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
                                    if (snapshot.data!.data() != null)
                                      if(!snapshot.data!['inClient'])
                                        Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: LatLng(cubit.position!.latitude,
                                            cubit.position!.longitude),
                                        builder: (ctx) => const Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    if (snapshot.data!.data() != null)
                                      if(snapshot.data!['inClient'])
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: LatLng(cubit.position!.latitude,
                                            cubit.position!.longitude),
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
                                    if (snapshot.data!.data() != null)
                                      if (!snapshot.data!['inClient'] &&
                                          snapshot.data!['isSelected'])
                                        Polyline(points: [
                                          LatLng(cubit.position!.latitude,
                                              cubit.position!.longitude),
                                          LatLng(
                                              snapshot.data!.get('clientLat'),
                                              snapshot.data!.get('clientLng'))
                                        ], strokeWidth: 4, color: Colors.red),
                                    if (snapshot.data!.data() != null)
                                      if (snapshot.data!['inClient']&&snapshot.data!['isStarted'])
                                        Polyline(points: [
                                          LatLng(cubit.position!.latitude,
                                              cubit.position!.longitude),
                                          LatLng(snapshot.data!.get('lat'),
                                              snapshot.data!.get('lng'))
                                        ], strokeWidth: 4, color: Colors.blue),
                                  ],
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('orders')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState.name == 'active'){
                                    if (snapshot.data!.docs.isNotEmpty) {
                                      if (snapshot.data!.docs
                                          .any((e) => !e.get('isSelected'))) {
                                        return Padding(
                                          padding:
                                          const EdgeInsetsDirectional.all(40),
                                          child: Stack(
                                            alignment:
                                            AlignmentDirectional.centerEnd,
                                            children: [
                                              defaultButton(
                                                text: 'Orders await',
                                                function: () {
                                                  openDialog(context,
                                                      snapshot.data!.docs);
                                                },
                                              ),
                                              const CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors.red,
                                                  child: Text(
                                                    'New',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  )),
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    } else {
                                      return Container();
                                    }
                                  }else{
                                    return Container();
                                  }
                                }),
                            Builder(builder: (context){
                              if (snapshot.data!.data() != null) {
                                if (snapshot.data!['isSelected'] &&
                                    !snapshot.data!['inClient'] &&
                                    snapshot.data!['clientLat'] ==
                                        cubit.position!.latitude) {
                                  return Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: defaultButton(
                                        function: () {
                                          cubit.driverInClient();
                                          cubit.chooseDistance(
                                              pos: LatLng(
                                                  snapshot.data!['lat'],
                                                  snapshot.data!['lng']));
                                        },
                                        text: 'Start Order'),
                                  );
                                }
                                return Container();
                              } else {
                                return Container();
                              }
                            }),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                );
              });
        });
  }
}
