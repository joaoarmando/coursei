import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/interfaces/i_courses_repository.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

class CoursesBloc extends BlocBase {
  SharedPreferences prefs;
  ICoursesRepositroy repository;
  
  final _savedCourseStateController = BehaviorSubject<bool>();
  final _savedCoursesController = BehaviorSubject<int>.seeded(0);
  Stream<bool> get outSavedCoursesState => _savedCourseStateController.stream;
  Stream<int> get outSavedCourses => _savedCoursesController.stream;

  List<String> savedCourses = [];
  bool alreadyStarted = false;


  CoursesBloc({@required this.prefs, @required this.repository}){
    getSavedCoursesCountFromServer();
  }
 
  void saveCourse(CourseData course) async {
    _savedCourseStateController.sink.add(true);
    final success = await repository.saveCourse(course);
    if (success) {
        if (savedCourses.indexOf(course.objectId) == -1) savedCourses.add(course.objectId);
        updateSavedCoursesCount(increment: true);
    }
    if (!success) _savedCourseStateController.sink.add(false);

  }
  void removeSavedCourse(CourseData course) async {
     _savedCourseStateController.sink.add(false);
    final success = await repository.removeSavedCourse(course);
    if (success) {
        if (savedCourses.indexOf(course.objectId) != -1) savedCourses.remove(course.objectId);
        updateSavedCoursesCount(increment: false);
    }
    if (!success) _savedCourseStateController.sink.add(true);
   
  }

  void getSavedCourses() async {

    ParseUser user = await ParseUser.currentUser();
    if (user != null){
      var userSavedCourses = user.get("savedCourses");
      if (userSavedCourses != null){
          savedCourses = List<String>.from(userSavedCourses);
      }
    }
    
  }

  void updateSavedCoursesCount({@required bool increment}){
    int newValue = increment ? (_savedCoursesController.value + 1) :  (_savedCoursesController.value - 1);
    if (newValue < 0) newValue = 0;
    _savedCoursesController.sink.add(newValue);
     prefs.setInt('savedCoursesCount', newValue);
  }
  
  void getSavedCoursesCount() async {
    if (prefs == null) await Future.delayed(Duration(seconds:1));

    if (prefs != null){
       int savedCoursesCount = (prefs.getInt('savedCoursesCount') ?? 0);
      _savedCoursesController.sink.add(savedCoursesCount);
    }
     
  }
  
  void clearNotificationBadge() async {
    repository.clearNotificationBadge();
    _savedCoursesController.sink.add(0);
  }

  void getSavedCoursesCountFromServer() async {
    final notificationBadge = await repository.getSavedCoursesCountFromServer();
    _savedCoursesController.sink.add(notificationBadge);
  }

  void goToCourse(CourseData course) async {

    String url = course.url;

    // if (!alreadyStarted){
    //     alreadyStarted = true;
    //     sendClickStartCourse(course);
    // }

    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  bool userHasSavedCourse(String courseId) {
    bool founded = savedCourses.indexOf(courseId) != -1;
    _savedCourseStateController.sink.add(founded);
    return founded;
  }

  @override
  void dispose(){
    _savedCourseStateController.close();
    _savedCoursesController.close();
    super.dispose();
  }
}