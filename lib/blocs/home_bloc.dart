import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/interfaces/courses_repository_interface.dart';
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

  int categoryId = -1 ;
  List<Map<String,dynamic>> cachedCourses = [];

  SharedPreferences prefs;



  void nextPage(){
    getNextPage(categoryId);
  }

  void getCategories() async {
    List<CategoryData> categorieList = await repository.getCourseCategories();
    _categoriesController.sink.add(categorieList);
  }

  void tryAgainNextPage(){
    _coursesController.sink.add(_getCoursesFromCache());
  }

  Map<String,dynamic> _getCoursesFromCache(){
    Map<String,dynamic> cached;
    var cachedIndex = getIndexInCachedCourses(categoryId);
    if (cachedIndex != -1){
      cached = cachedCourses[cachedIndex];
      return cached;
    }
    return null;
  }
  
  void getCourses(int categoryId) async {
    // return from cache if this data is already fetched
    Map<String,dynamic> cached = _getCoursesFromCache();
    if (cached != null){
        cached["canAnimate"] = true;
        _coursesController.sink.add(cached);
        return null;
    }

    _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
    bool hasInternet = await hasInternetConnection(true);
    if (!hasInternet){
      _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
      return null;
    }

    final courseList = await repository.getCourses(categoryId: categoryId);
    bool hasMoreCourses = courseList.length > 10;    
    if (cached == null){
      cached = {"categoryId": categoryId, "courses":courseList, "hasMore":hasMoreCourses,"canAnimate":true};
      cachedCourses.add(cached);
    }
    _coursesController.sink.add(cached);


    _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
    _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);

    
    return null;    
  }

  void getNextPage(int categoryId) async {
     // return from cache if this data is already fetched
    Map<String,dynamic> cached = _getCoursesFromCache();
    var cachedIndex = getIndexInCachedCourses(categoryId);
    cached["canAnimate"] = true;

    final courseList = await repository.getCourses(categoryId: categoryId, skipCount: cached["courses"].length);
    final hasNextPage = courseList.length > 0;

    cached["courses"].addAll(courseList);
    cached["hasMore"] = hasNextPage;
    cached["canAnimate"] = false;
    cachedCourses[cachedIndex] = cached;      
    _coursesController.sink.add(cached);
    return;    
  }

  
  void retryLoad(){
    getCategories();
    getCourses(categoryId);
  }

  int getIndexInCachedCourses(int categoryId){
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