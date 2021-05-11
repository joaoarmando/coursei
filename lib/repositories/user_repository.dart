import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

class UserRepository {

  SharedPreferences prefs;
  UserRepository(this.prefs);

  Future<ParseUser> checkLogin() async {
    ParseUser user;
    user = await ParseUser.currentUser();
    print("current: $user");
    if (user == null) return null;

    var response = await ParseUser.getCurrentUserFromServer(user.sessionToken);
    if (response?.success ?? false) {
        user = response.result;
    }else {
      if (response.error.code == 209){
        user.logout();
        return null;
             
      }
    }
    return user;
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

  
  Future<Null> logout() async {
    ParseUser user = await ParseUser.currentUser();
    if (user != null) user.logout();
    return;
  }

  Future<Null> deleteAccount() async{
    ParseUser user = await ParseUser.currentUser();
    if (user != null){
      ParseResponse apiResponse = await user.destroy();
      if (apiResponse.success){
          user.logout();       
      }
    }
    return;
  }

}