import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/repositories/user_repository.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DialogState{DIALOG_OPTIONS,LOGIN_STATE,LOGIN_SUCCESSFULLY}
class UserBloc extends BlocBase{

  ParseUser user;
  final UserRepository repository;
  final SharedPreferences prefs;

  final _userController = BehaviorSubject<ParseUser>();
  final _dialogStateController = BehaviorSubject<DialogState>();
  final _savedCourseStateController = BehaviorSubject<bool>();
  final _savedCoursesController = BehaviorSubject<int>.seeded(0);

  Stream<bool> get outSavedCoursesState => _savedCourseStateController.stream;
  Stream<int> get outSavedCourses => _savedCoursesController.stream;  
  Stream get outUser => _userController.stream;
  Stream<DialogState> get outDialogState => _dialogStateController.stream;

  List<String> savedCourses = [];
  UserBloc(this.repository, this.prefs) {
    checkLogin();
    getSavedCoursesFromCache();
    getSavedCoursesCountFromServer();
  }


  void saveCourse(CourseData course) async {
    _savedCourseStateController.sink.add(true);
    final success = await repository.saveCourse(course.objectId);
    if (success) {
        if (savedCourses.indexOf(course.objectId) == -1) savedCourses.add(course.objectId);
        updateSavedCoursesCount(increment: true);
    }
    if (!success) _savedCourseStateController.sink.add(false);

  }

  void removeSavedCourse(CourseData course) async {
     _savedCourseStateController.sink.add(false);
    final success = await repository.removeSavedCourse(course.objectId);
    if (success) {
        if (savedCourses.indexOf(course.objectId) != -1) savedCourses.remove(course.objectId);
        updateSavedCoursesCount(increment: false);
    }
    if (!success) _savedCourseStateController.sink.add(true);   
  }

  void getSavedCoursesFromCache() async {
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
  
  int getSavedCoursesCount() {
    int savedCoursesCount = (prefs.getInt('savedCoursesCount') ?? 0);
    _savedCoursesController.sink.add(savedCoursesCount);
    return savedCoursesCount;     
  }
  
  void clearNotificationBadge() async {
    repository.clearNotificationBadge();
    _savedCoursesController.sink.add(0);
  }

  void getSavedCoursesCountFromServer() async {
    final notificationBadge = await repository.getSavedCoursesCountFromServer();
    _savedCoursesController.sink.add(notificationBadge);
  }

  bool userHasSavedCourse(String courseId) {
    bool founded = savedCourses.indexOf(courseId) != -1;
    _savedCourseStateController.sink.add(founded);
    return founded;
  }

  Future<Null> checkLogin() async {
    user = await repository.checkLogin();
    setUser(user);   
    return;
  }

  void setUser(ParseUser u){
    user = u;
    _userController.add(user);
  }

  bool verifySignIn () => user != null;

  Future<Null> logout() async{
    await repository.logout();
    setUser(null);
    return;
  }

  Future<Null> deleteAccount() async {
    await repository.deleteAccount();
    setUser(null);
    return;
  }

  void goToSignIn() async {
    await Future.delayed(Duration(milliseconds: 150));
    _dialogStateController.add(DialogState.LOGIN_STATE);
  }

  void backToDefaultDialog() async {
    await Future.delayed(Duration(milliseconds: 300));
    _dialogStateController.add(DialogState.DIALOG_OPTIONS);
  }  

  @override
  void dispose(){
    _savedCourseStateController.close();
    _savedCoursesController.close();
    _userController.close();
    _dialogStateController.close();
    super.dispose();
  }

}