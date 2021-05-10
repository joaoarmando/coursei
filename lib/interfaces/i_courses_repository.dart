import 'package:coursei/repositories/courses_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ICoursesRepositroy extends CoursesRepository {
  ICoursesRepositroy(SharedPreferences prefs) : super(prefs);
}