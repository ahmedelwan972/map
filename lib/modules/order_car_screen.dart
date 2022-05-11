import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/layout/cubit/states.dart';
import 'package:map/layout/home_page_client_screen.dart';
import 'package:map/models/all_users_model.dart';
import 'package:map/shared/components/components.dart';

import '../layout/cubit/cubit.dart';

class OrderCarScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = MapCubit.get(context);

          return  Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title:const Text('Tap To Choose Location'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),
            body: FlutterMap(
              options: MapOptions(
                onTap: (v,l){
                  cubit.chooseDistance(pos: l);
                  cubit.getCurrentAddress();
                  cubit.getDistanceAddress();
                  cubit.getAllDriver().then((value) {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.transparent,
                      builder: (context)=> Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.all(20),
                          child: Column(
                            children: [
                              if(cubit.currentCountry.isNotEmpty&&cubit.distanceCountry.isNotEmpty)
                                Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('From : ${cubit.currentCountry} ,${cubit.currentCity}',style:const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
                                      Text('To       : ${cubit.distanceCountry} ,${cubit.distanceCity}',style:const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,)),
                                    ],
                                  ),
                                ),
                              ),
                              Text('Drivers',style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold,color: Colors.green),),
                              Expanded(
                                child: ListView.separated(
                                  itemBuilder: (context,index)=>bottomSheet(context,cubit.allUsersModel[index],MapCubit.get(context).distance[index]),
                                  separatorBuilder: (context,index)=> const SizedBox(height: 10,),
                                  itemCount: cubit.allUsersModel.length ,
                                ),
                              ),
                            ],
                          ),
                      ),
                    );
                  });
                },
               // bounds: LatLngBounds(LatLng(cubit.position!.latitude,cubit.position!.longitude), LatLng(cubit.position!.latitude,cubit.position!.longitude)),
                center: LatLng(cubit.position!.latitude,cubit.position!.longitude),
                zoom: 14.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  attributionBuilder: (_) {
                    return const Text("© OpenStreetMap contributors");
                  },
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(cubit.position!.latitude,cubit.position!.longitude),
                      builder: (ctx) =>
                      const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                    if(cubit.distantion!= null) cubit.distantion!,
                  ],
                ),
                PolylineLayerOptions(
                  polylines: [
                    if(cubit.distantion!= null)
                    Polyline(
                        points: [
                          LatLng(cubit.position!.latitude, cubit.position!.longitude),
                          LatLng(cubit.distantion!.point.latitude, cubit.distantion!.point.longitude)
                        ],
                        //cubit.routeModel!.routes![0].geometry!.coordinates!
                        strokeWidth: 4,
                        color: Colors.blue,
                    ),
                  ],
                  polylineCulling: true
                ),
              ],
            ),
          );
        }
    );
  }

  bottomSheet(context,AllUsersModel model,distance){
    return !model.client! ?Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name : ${model.name}'),
                Text('Phone Number : ${model.phone}'),
                Text('Distance : ${distance /1000} km'),
              ],
            ),
            const Spacer(),
            defaultButton(
              text: 'Order Now',
              function:(){
                MapCubit.get(context).driverIsSelected(driver: model.uId!,driveLng: model.long!,driverLat: model.lat!);
                navigateAndFinish(context, HomePageClientScreen());
              },
              width: 130,
            ),
          ],
        ),
      ),
    ) : Container();
  }

}
