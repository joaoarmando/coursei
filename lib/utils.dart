import 'dart:io';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
enum LoadingCoursesState{IDLE,LOADING,NO_INTERNET_CONNECTION,SUCCESS}
FirebaseAnalytics analytics;

void setAnalytics(analy){
  analytics = analy;
}
Future<bool> hasInternetConnection(bool useDelay) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (useDelay) await Future.delayed(Duration(milliseconds:600)); // REMOVE ISSO DPS
        return true; // <= FAZ ISSO RETORNAR TRUE DPS
      }
    } on SocketException catch (_) {
      if (useDelay) await Future.delayed(Duration(milliseconds:600));
      return false;
    }
    return false;
  }

  Future<void> sendClickCourse(CourseData course) async {
    _sendClickCourseParseServer(course,"clickDetails");
    await analytics.logEvent(
      name: 'CourseDetails',
      parameters: <String,dynamic>{
        "title": course.title,
        "courseId": course.objectId,
      },
    );

  }

  Future<void> sendClickStartCourse(CourseData course) async {
    _sendClickCourseParseServer(course,"clickStartCourse");
    await analytics.logEvent(
      name: 'CourseStart',
      parameters: <String,dynamic>{
        "title": course.title,
        "courseId": course.objectId,
      },
    );

  }

  Future<void> sendClickCategory(CategoryData category) async {
    await analytics.logEvent(
      name: 'CategoryDetails',
      parameters: <String,dynamic>{
        "categoryName": category.categoryName,
        "categoryId": category.categoryId,
      },
    );

  }
  
  void _sendClickCourseParseServer(CourseData course, String type) async {
    final ParseCloudFunction function = ParseCloudFunction('clickDetails');
    final Map<String, String> params = <String, String>{'objectId': course.objectId, "type": type};
    try{
      function.execute(parameters: params);
    }catch(e){

    }
    
  }