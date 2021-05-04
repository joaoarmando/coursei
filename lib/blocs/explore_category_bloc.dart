import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/saved_screen_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursei/utils.dart';

class ExploreCategoryBloc extends BlocBase {
  final _selectController = BehaviorSubject<int>();
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();
  final _categoriesController = BehaviorSubject<List<CategoryData>>();

  Stream<int> get outSelected => _selectController.stream;

  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<List<CategoryData>> get outCategories => _categoriesController.stream;
  List<Map<String,dynamic>> cachedCourses = [];
  int categoryId = -1 ;
  SharedPreferences prefs;
  List<String> savedCourses = [];
  SavedCourseScreenBloc savedCourseScreenBloc;




  void selectCategory(int _categoryId){
    if (categoryId != null){
      categoryId = _categoryId;
      _selectController.sink.add(categoryId);
    }
    getCourses(categoryId,false);

  }
  void nextPage(){
    getCourses(categoryId,true);
  }

  void tryAgainNextPage(){
    _coursesController.sink.add(getCoursesCache());
  }
  Map<String,dynamic> getCoursesCache(){
    Map<String,dynamic> cached;
    var cachedIndex = getIndex(categoryId);
    if (cachedIndex != -1){
      cached = cachedCourses[cachedIndex];
      return cached;
    }
    return null;
  }
  void getCourses(int categoryId, bool nextPage) async{
    Map<String,dynamic> cached = getCoursesCache();
    var cachedIndex = getIndex(categoryId);
    if (cached != null){
      if (!nextPage) {
         cached["canAnimate"] = true;
        _coursesController.sink.add(cached);
        return null;
      } 
    }


    if (!nextPage) {
        _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
        bool isConnected = await hasInternetConnection(true);
        if (!isConnected){
          _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
          return null;
        }
    }
 

   

    if (!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
    List<int> categoriesList = [categoryId];
    var queryBuilder = QueryBuilder(ParseObject('Courses'))..setLimit(10);

    if (categoryId != -1) queryBuilder.whereContainedIn("categories", categoriesList);
    if (nextPage) queryBuilder.setAmountToSkip(cached["courses"].length);
    queryBuilder.whereEqualTo("isPaid", false);
    queryBuilder.orderByDescending("isHighlight");
    
    
    List<CourseData> courseList = [];
    

    var apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há cursos
        for (var course in apiResponse.result){

          int index = -1;
          if (cached != null) index =  getCourseIndex(course.objectId,cached["courses"]);
          if (index == -1) courseList.add(CourseData.fromParseObject(course));
        }
      }
      
      bool hasMoreCourses = courseList.length > 9;

      if (cached == null){
        cached = {"categoryId": categoryId, "courses":courseList, "hasMore":hasMoreCourses, "canAnimate": true};
        cachedCourses.add(cached);
      }else {
        cached["courses"].addAll(courseList);
        cached["hasMore"] = hasMoreCourses;
        cached["canAnimate"] = false;
        cachedCourses[cachedIndex] = cached;
      }

      if(!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);
      _coursesController.sink.add(cached);

    }
    return null;    
  }

  int getCourseIndex(String objectId,List<CourseData> courseList){
    for (var i = 0; i < courseList.length; i++){
      if (courseList[i].objectId == objectId){
          return i;
      }
    }
    return -1;
  }
  
  void retryLoad(){
    getCourses(categoryId, false);
  }


  int getIndex(int categoryId){
    for (var i = 0; i < cachedCourses.length; i++){
      if (cachedCourses[i]["categoryId"] == categoryId)
        return i;
    }
    return -1;
  }

 @override
  void dispose(){
    _selectController.close();
    _refreshCourseListController.close();
    _coursesController.close();
    _categoriesController.close();
    super.dispose();
  }
}