import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/screens/home.dart';
import 'package:coursei/utils.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final _userBloc = UserBloc();
  final _homeBloc = HomeBloc(); 
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  
  @override
  Widget build(BuildContext context) {
    setAnalytics(analytics);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocProvider(
      blocs: [
         Bloc((i) => _userBloc),
         Bloc((i) => _homeBloc),
      ],
      child: FutureBuilder(
        future: _userBloc.startParseServer(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done)
            return MaterialApp(
              title: 'Coursei',
              
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: "SourceSansPro",
              ),
              debugShowCheckedModeBanner: false,
              home: Home(observer),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              
            );
          else return Container();  
        },

      ),
    );
  }
}
