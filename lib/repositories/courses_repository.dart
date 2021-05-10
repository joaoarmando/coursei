import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursesRepository {

  SharedPreferences prefs;

  CoursesRepository(this.prefs);

  Future<List<CategoryData>> getCourseCategories() async {
    List<CategoryData> categorieList = [];
    var apiResponse = await ParseObject('Categories').getAll();
    if (apiResponse.success && apiResponse.result != null){
        ParseObject categories = apiResponse.result.first;
        categories.get("categories").forEach((category) 
          => categorieList.add(CategoryData.fromJSON(category))
        );
    }
    return categorieList;
  }

  Future<bool> saveCourse(String courseId) async{
    ParseUser user = await  ParseUser.currentUser();
    user.setAddUnique("savedCourses", courseId);

    var response = await user.save();

    if (response.success) {
        updateBadge(increment: true);
    }

    return response.success;
  }

  Future<bool> removeSavedCourse(String courseId) async{
    ParseUser user = await  ParseUser.currentUser();
    user.setRemove("savedCourses", courseId);
    var response = await user.save();

    if (response.success) {
        updateBadge(increment: false);
    }
    return response.success;
  }

  Future<int> getSavedCoursesCountFromServer() async{
    ParseUser user = await ParseUser.currentUser();
    if (user != null){
        final response = await ParseUser.getCurrentUserFromServer(user.sessionToken);
        if (response?.success ?? false) user = response.result;      

        var notificationBadge = user.get("notificationBadge");
        if (notificationBadge == null || notificationBadge < 0) notificationBadge = 0;
        prefs.setInt('savedCoursesCount', notificationBadge);
        return notificationBadge;
    }
    return 0;
  }

  Future<Null> clearNotificationBadge() async{
    ParseUser user = await ParseUser.currentUser();
    prefs.setInt('savedCoursesCount', 0);
    if (user != null){
      user.set("notificationsBadge",0);
      user.save();
    }
    return;
  }

  void updateBadge({@required bool increment}){
     final ParseCloudFunction function = ParseCloudFunction('updateBadge');
      final Map<String, String> params = <String, String>{'increment': increment.toString()};
      function.execute(parameters: params);
  }
}