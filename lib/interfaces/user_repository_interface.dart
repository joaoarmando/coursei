import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

abstract class IUserRespotiroy{

  Future<ParseUser> checkLogin();

  Future<bool> saveCourse(String courseId);

  Future<bool> removeSavedCourse(String courseId);

  Future<int> getSavedCoursesCountFromServer();

  Future<Null> clearNotificationBadge();
  
  Future<Null> logout();

  Future<Null> deleteAccount();

}