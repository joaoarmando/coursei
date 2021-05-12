import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/saved_screen_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/interfaces/courses_repository_interface.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursei/utils.dart';

class ExploreCategoryBloc extends BlocBase {
  ICoursesRepositroy repository;

  final _selectController = BehaviorSubject<int>();
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();
  final _categoriesController = BehaviorSubject<List<CategoryData>>();

  Stream<int> get outSelected => _selectController.stream;

  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<List<CategoryData>> get outCategories => _categoriesController.stream;
  Map<String,dynamic> cachedCourses;
  int categoryId = -1 ;
  SharedPreferences prefs;
  List<String> savedCourses = [];
  SavedCourseScreenBloc savedCourseScreenBloc;
  ExploreCategoryBloc(this.categoryId, this.repository) {
    getCourses(categoryId);
  }


  void nextPage(){
    getNextPage(categoryId);
  }

  void tryAgainNextPage(){
    _coursesController.sink.add(cachedCourses);
  }


  void getCourses(int categoryId) async {
    // return from cache if this data is already fetched
    Map<String,dynamic> cached = cachedCourses;
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
      cachedCourses = cached;
    }
    
    _coursesController.sink.add(cached);


    _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
    _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);

    
    return null;    
  }

  void getNextPage(int categoryId) async {
     // return from cache if this data is already fetched
    Map<String,dynamic> cached = cachedCourses;
    cached["canAnimate"] = true;

    final courseList = await repository.getCourses(categoryId: categoryId, skipCount: cached["courses"].length);
    final hasNextPage = courseList.length > 0;

    cached["courses"].addAll(courseList);
    cached["hasMore"] = hasNextPage;
    cached["canAnimate"] = false;
    cachedCourses = cached;      
    _coursesController.sink.add(cached);
    return;    
  }

  
  void retryLoad(){
    getCourses(categoryId);
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