import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/layout/cubit/states.dart';
import 'package:map/layout/home_page_screen.dart';
import 'package:map/shared/components/constants.dart';
import 'package:map/shared/local/cache_helper.dart';
import 'layout/cubit/cubit.dart';
import 'layout/home_page_client_screen.dart';
import 'shared/bloc_observer.dart';
import 'modules/auth/login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp();
  uId = CacheHelper.getData(key: 'uId');
  driverId = CacheHelper.getData(key: 'driverId');
  client = CacheHelper.getData(key: 'client');
  // Widget widget;
  // if(uId != null){
  //   if(client)
  // }
  BlocOverrides.runZoned(
        () {
      runApp( MyApp());
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>MapCubit()..getUserData()..getCurrentLocation(),
      child: BlocConsumer<MapCubit,MapStates>(
        listener: (context,state){},
        builder: (context,state){
          var cubit = MapCubit.get(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: uId != null && client != null ? client! ?  HomePageClientScreen() :HomePageScreen(): LoginScreen(),
          );
        },
      ),
    );
  }
}
