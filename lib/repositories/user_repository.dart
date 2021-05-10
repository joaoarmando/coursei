import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class UserRepository {


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

}