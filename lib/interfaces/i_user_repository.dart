import 'package:coursei/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IUserRespotiroy extends UserRepository {
  IUserRespotiroy(SharedPreferences prefs) : super(prefs);
}