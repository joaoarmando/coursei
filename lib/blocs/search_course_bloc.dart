import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';
enum ListController{IDLE,LOADING,FINDED,NO_INTERNET_CONNECTION}
class SearchCourseBloc extends BlocBase {
  Timer _timer;


  final _refreshCourseListController = BehaviorSubject<ListController>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>.seeded(null);



  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<ListController> get outCourseListRefresh => _refreshCourseListController.stream;
  List<Map<String,dynamic>> cachedCourses = [];
  String search = "";
  List<String> savedCourses = [];
 
  
  void searchCourses(String _search){

     if (_timer != null) _timer.cancel();
    _timer = new Timer(Duration(milliseconds: 500), () {

        
        if (_search != search && _search.trim().length > 0)  {
          getCourses(_search,false);
          
        }else {
          _refreshCourseListController.sink.add(ListController.IDLE);
          _coursesController.sink.add(null);
        }
        search = _search;

    });
  }
  void retryLoad(){
    getCourses(search,false);
  }
  void nextPage(){
    getCourses(search,true);
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

  void getCourses(String search, bool nextPage) async{

    Map<String,dynamic> cached;
    var cachedIndex = search == null ? -1 : getIndex(search);
    if (cachedIndex != -1){
      cached = cachedCourses[cachedIndex];
      if (!nextPage) {
        _coursesController.sink.add(cached);
        return null;
      } 
    }

    if (!nextPage) {
      _refreshCourseListController.sink.add(ListController.LOADING);
       bool isConnected = await hasInternetConnection(true);

         if (!isConnected ){
             _refreshCourseListController.sink.add(ListController.NO_INTERNET_CONNECTION);
              return null;
         }
 
    
    
    }

    if (search != "" && search != null){
        final ParseCloudFunction function = ParseCloudFunction('searchCourse');
        final Map<String, String> params = <String, String>{
          'search': search,
          "skipCount": nextPage ? cached["courses"].length.toString() : "0"
        };
        final apiResponse = await function.execute(parameters: params);
        List<CourseData> courseList = [];

          if (apiResponse.success){
            if (apiResponse.result != null){
              //Há cursos
              for (var course in apiResponse.result){
                courseList.add(CourseData.fromMap(course));
              }
            }
            
            bool hasMoreCourses = courseList.length > 9;

            if (cached == null){
              cached = {"search": search, "courses":courseList, "hasMore":hasMoreCourses};
              cachedCourses.add(cached);
            }else {
              cached["courses"].addAll(courseList);
              cached["hasMore"] = hasMoreCourses;
              cachedCourses[cachedIndex] = cached;
            }

            if(!nextPage) _refreshCourseListController.sink.add(ListController.FINDED);
            _coursesController.sink.add(cached);

          }

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