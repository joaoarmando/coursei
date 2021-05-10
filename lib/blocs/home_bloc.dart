import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/interfaces/i_courses_repository.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursei/utils.dart';
import 'package:meta/meta.dart';

class HomeBloc extends BlocBase {
  ICoursesRepositroy repository;

  HomeBloc({@required this.prefs, @required this.repository}) {
    getCategories();
    getCourses(-1);
  }
  
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();
  final _categoriesController = BehaviorSubject<List<CategoryData>>();

  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<List<CategoryData>> get outCategories => _categoriesController.stream;
  List<Map<String,dynamic>> cachedCourses = [];
  int categoryId = -1 ;
  SharedPreferences prefs;




  void nextPage(){
    getNextPage(categoryId);
  }

  void getCategories() async {
    List<CategoryData> categorieList = await repository.getCourseCategories();
    _categoriesController.sink.add(categorieList);
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
  
  void getCourses(int categoryId) async {
    // return from cache if this data is already fetched
    Map<String,dynamic> cached = getCoursesCache();
    var cachedIndex = getIndex(categoryId);
    if (cached != null){
        cached["canAnimate"] = true;
        _coursesController.sink.add(cached);
        return null;
    }

    _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
    bool isConnected = await hasInternetConnection(true);
    if (!isConnected){
      _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
      return null;
    }
    
    var queryBuilder = QueryBuilder(ParseObject('Courses'));  
    if (categoryId != -1) queryBuilder.whereContainedIn("categories", [categoryId]);
    queryBuilder.setLimit(11);
    queryBuilder.whereEqualTo("isPaid", false);
    queryBuilder.orderByDescending("isHighlight");    
    queryBuilder.orderByDescending("createdAt");    
    

    var apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.result != null){
        List<CourseData> courseList = [];  
        for (var course in apiResponse.result) {
            courseList.add(CourseData.fromParseObject(course));
        }

      bool hasMoreCourses = courseList.length > 10;
      if (hasMoreCourses) {
        //remove the last item to make sure that when user scroll he can see a new item after loading
        courseList.remove(courseList.last);
      }

      if (cached == null){
        cached = {"categoryId": categoryId, "courses":courseList, "hasMore":hasMoreCourses,"canAnimate":true};
        cachedCourses.add(cached);
      }

      _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
      _coursesController.sink.add(cached);
      _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);

    }
    return null;    
  }

  void getNextPage(int categoryId) async {
     // return from cache if this data is already fetched
    Map<String,dynamic> cached = getCoursesCache();
    var cachedIndex = getIndex(categoryId);
    cached["canAnimate"] = true;


    var queryBuilder = QueryBuilder(ParseObject('Courses'))..setLimit(11);

    if (categoryId != -1) queryBuilder.whereContainedIn("categories", [categoryId]);
    print("Skip amount: ${cached["courses"].length}");
    queryBuilder.setAmountToSkip(cached["courses"].length); 
    queryBuilder.whereEqualTo("isPaid", false);
    queryBuilder.orderByDescending("isHighlight");
    queryBuilder.orderByDescending("createdAt"); 
    final apiResponse = await queryBuilder.query();


    if (apiResponse.success && apiResponse.result != null ){
        List<CourseData> courseList = [];  

        for (var course in apiResponse.result) {
            courseList.add(CourseData.fromParseObject(course));
        }

        bool hasMoreCourses = courseList.length > 10;
        if (hasMoreCourses) {
          //remove the last item to make sure that when user scroll he can see a new item after loading
          courseList.remove(courseList.last);
        }
        cached["courses"].addAll(courseList);
        cached["hasMore"] = hasMoreCourses;
        cached["canAnimate"] = false;
        cachedCourses[cachedIndex] = cached;      
        _coursesController.sink.add(cached);

    }
    return;    
  }

  
  void retryLoad(){
    getCategories();
    getCourses(categoryId);
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
    _refreshCourseListController.close();
    _coursesController.close();
    _categoriesController.close();
    super.dispose();
  }
}