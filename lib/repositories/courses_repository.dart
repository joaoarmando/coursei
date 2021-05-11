import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
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

  Future<List<CourseData>> getCourses({int categoryId = -1, int skipCount = 0, String searchText}) async {
    //when categoryId is -1 get All Courses without set a category to the query
    List<CourseData> courseList = [];

    var queryBuilder = QueryBuilder(ParseObject('Courses'))..setLimit(11);

    if (categoryId != -1) queryBuilder.whereContainedIn("categories", [categoryId]);
    queryBuilder.setAmountToSkip(skipCount); 
    queryBuilder.whereEqualTo("isPaid", false);
    queryBuilder.orderByDescending("isHighlight");
    queryBuilder.orderByDescending("createdAt");
    if (searchText != null) queryBuilder.whereContains("keywords", searchText);
    final apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.result != null ){       
        for (var course in apiResponse.result) {
            courseList.add(CourseData.fromParseObject(course));
        }
    }
    return courseList;   
  }
 }