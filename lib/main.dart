import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/courses_bloc.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/interfaces/i_user_repository.dart';
import 'package:coursei/repositories/user_repository.dart';
import 'package:coursei/screens/home.dart';
import 'package:coursei/utils.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interfaces/i_courses_repository.dart';

void main() async {
  SharedPreferences prefs;
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await Parse().initialize(
    "HRqijQCx4H7hrms935HH",
    "https://coursei.herokuapp.com/parse/",
    autoSendSessionId: true,
  );
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final SharedPreferences prefs;
  MyApp(this.prefs);
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  
  @override
  Widget build(BuildContext context) {
    final userRepository = IUserRespotiroy(prefs);
    final courseRepository = ICoursesRepositroy(prefs);
    final _userBloc = UserBloc(userRepository);
    final _homeBloc = HomeBloc(prefs: prefs, repository: courseRepository);
    final _coursesBloc = CoursesBloc(prefs: prefs, coursesRepository: courseRepository, userRespotiroy: userRepository); 

    setAnalytics(analytics);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocProvider(
      blocs: [
         Bloc((i) => _userBloc),
         Bloc((i) => _homeBloc),
         Bloc((i) => _coursesBloc),
      ],
      child: MaterialApp(
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
      ),
      dependencies: [
        Dependency((i) => userRepository),
        Dependency((i) => courseRepository),
      ],
    );
  }
}
