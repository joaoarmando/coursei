import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/repositories/courses_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';
enum ListController{IDLE,LOADING,FINDED,NO_INTERNET_CONNECTION}
class SearchCourseBloc extends BlocBase {
  Timer _timer;

  final CoursesRepository coursesRepository;
  final _refreshCourseListController = BehaviorSubject<ListController>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>.seeded(null);

  SearchCourseBloc(this.coursesRepository);


  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<ListController> get outCourseListRefresh => _refreshCourseListController.stream;
  List<Map<String,dynamic>> cachedCourses = [];
  String search = "";
 
  
  void onChangeSearchText(String _search){

     if (_timer != null) _timer.cancel();
    _timer = new Timer(Duration(milliseconds: 500), () {

        
        if (_search != search && _search.trim().length > 0)  {
          getCourses(_search, isNextPage: false);
          
        }else {
          _refreshCourseListController.sink.add(ListController.IDLE);
          _coursesController.sink.add(null);
        }
        search = _search;

    });
  }
  
  void retryLoad(){
    getCourses(search, isNextPage: false);
  }
  void nextPage(){
    getCourses(search, isNextPage: true);
  }

  void tryAgainNextPage(){
    _coursesController.sink.add(getCoursesCache());
  }
   
  Map<String,dynamic> getCoursesCache(){
    Map<String,dynamic> cached;
    var cachedIndex = getIndex(search);
    if (cachedIndex != -1){
      cached = cachedCourses[cachedIndex];
      return cached;
    }
    return null;
  }

  void getCourses(String search, {bool isNextPage = false}) async {

    Map<String,dynamic> cached;
    var cachedIndex = search == null ? -1 : getIndex(search);
    if (cachedIndex != -1){
      cached = cachedCourses[cachedIndex];
      if (!isNextPage) {
        _coursesController.sink.add(cached);
        return null;
      } 
    }

    if (!isNextPage) {
      _refreshCourseListController.sink.add(ListController.LOADING);
       bool isConnected = await hasInternetConnection(true);
         if (!isConnected ){
             _refreshCourseListController.sink.add(ListController.NO_INTERNET_CONNECTION);
              return null;
         }  
    }

    if (search != "" && search != null){
        int skipCount = isNextPage ? cached["courses"].length : 0;
        List<CourseData> courseList = await coursesRepository.getCourses(searchText: search, skipCount: skipCount);
        bool hasMoreCourses = courseList.length > 9;

        if (cached == null){
          cached = {"search": search, "courses":courseList, "hasMore":hasMoreCourses};
          cachedCourses.add(cached);
        }else {
          cached["courses"].addAll(courseList);
          cached["hasMore"] = hasMoreCourses;
          cachedCourses[cachedIndex] = cached;
        }

        if(!isNextPage) _refreshCourseListController.sink.add(ListController.FINDED);
        _coursesController.sink.add(cached);

    }

    return null;    
  }
  
  int getIndex(String search){
    for (var i = 0; i < cachedCourses.length; i++){
      if (cachedCourses[i]["search"] == search)
        return i;
    }
    return -1;
  }


  @override
  void dispose(){
    _refreshCourseListController.close();
    _coursesController.close();
    super.dispose();
  }
}