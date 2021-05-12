import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';

abstract class ICoursesRepositroy {

  Future<List<CategoryData>> getCourseCategories();

  Future<List<CourseData>> getCourses({int categoryId = -1, int skipCount = 0, String searchText});
}