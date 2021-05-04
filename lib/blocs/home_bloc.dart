import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/saved_screen_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursei/utils.dart';

class HomeBloc extends BlocBase {
  final _selectController = BehaviorSubject<int>();
  final _savedCoursesController = BehaviorSubject<int>.seeded(0);
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();
  final _savedCourseStateController = BehaviorSubject<bool>();
  final _coursesController = BehaviorSubject<Map<String,dynamic>>();
  final _categoriesController = BehaviorSubject<List<CategoryData>>();

  Stream<int> get outSelected => _selectController.stream;
  Stream<int> get outSavedCourses => _savedCoursesController.stream;
  Stream<bool> get outSavedCoursesState => _savedCourseStateController.stream;
  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<List<CategoryData>> get outCategories => _categoriesController.stream;
  List<Map<String,dynamic>> cachedCourses = [];
  int categoryId = -1 ;
  SharedPreferences prefs;
  List<String> savedCourses = [];
  SavedCourseScreenBloc savedCourseScreenBloc;




  void selectCategory(int _categoryId){
    /* for(var i = 0; i < 50; i++){
      ParseObject("Courses")
        ..set("title", " $i Curso Web Moderno com JavaScript 2019 COMPLETO + Projetos")
        ..set("rate", 4.5)
        ..set("price",0)
        ..set("subscribers", 1500)
        ..set("contentLength",5.3)
        ..set("description", "Aprenda a criar programas em C e C++ do Zero, desenvolva sua lógica e adquira uma base sólida! Perfeito para iniciantes. - Curso gratuito")
        ..set("thumbnail", "https://i.udemycdn.com/course/480x270/1465244_ed1a_3.jpg")
        ..setAddAll("categories", [1207,1206])
        ..save();
    } */
    if (categoryId != null){
      categoryId = _categoryId;
      _selectController.sink.add(categoryId);
    }
    getCourses(categoryId,false);

  }
  void nextPage(){
    getCourses(categoryId,true);
  }

  void getCategories() async {
    List<CategoryData> categorieList = [];
    var apiResponse = await ParseObject('Categories').getAll();
    if (apiResponse.success){
      
      if (apiResponse.result != null)
        for (ParseObject categories in apiResponse.result){
            for (Map<String,dynamic> category in categories.get("categories")){
              categorieList.add(CategoryData.fromJSON(category));
            }
        }
      _categoriesController.sink.add(categorieList);
    } 
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
        cached = {"categoryId": categoryId, "courses":courseList, "hasMore":hasMoreCourses,"canAnimate":true};
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
    getCategories();
    getCourses(categoryId, false);
  }

  void updateSavedCoursesCount(bool increment){
    int newValue = increment ? (_savedCoursesController.value + 1) :  (_savedCoursesController.value - 1);
    if (newValue < 0) newValue = 0;
    _savedCoursesController.sink.add(newValue);
     prefs.setInt('savedCoursesCount', newValue);
  }
  int getIndex(int categoryId){
    for (var i = 0; i < cachedCourses.length; i++){
      if (cachedCourses[i]["categoryId"] == categoryId)
        return i;
    }
    return -1;
  }

  void startSharedPreferences() async{
     prefs = await SharedPreferences.getInstance();
     getSavedCoursesCountFromServer();
  }

  getSavedCoursesCount() async{
    if (prefs == null) await Future.delayed(Duration(seconds:1));

    if (prefs != null){
       int savedCoursesCount = (prefs.getInt('savedCoursesCount') ?? 0);
      _savedCoursesController.sink.add(savedCoursesCount);
    }
     
  }

  void getSavedCourses() async{
    //var savedCoursesShared = (prefs.getStringList('savedCourses') ?? []);
    ParseUser user = await ParseUser.currentUser();
    if (user != null){
      var _savedCourses = user.get("savedCourses");
      if (_savedCourses != null){
        savedCourses = List<String>.from(_savedCourses);
        //prefs.setStringList('savedCourses', _savedCourses);
      }
    }
    
  }
  Future<bool> saveCourse(CourseData course) async{
    String courseId = course.objectId;
    updateSavedCoursesCount(true);
    ParseUser user = await  ParseUser.currentUser();
    user.setAddUnique("savedCourses", courseId);

    updateBadge(true);

    var response = await user.save();

    if (response.error == null){ //SUCCESS
      if (savedCourses.indexOf(courseId) == -1)  savedCourses.add(courseId);
      if (savedCourseScreenBloc != null) savedCourseScreenBloc.addCourse(course);
      return true;
    } 

    else return false;
  }
  Future<bool> removeSavedCourse(CourseData course) async{
    String courseId = course.objectId;
    updateSavedCoursesCount(false);
    ParseUser user = await  ParseUser.currentUser();
    user.setRemove("savedCourses", courseId);

    updateBadge(false);

    if (savedCourseScreenBloc != null) savedCourseScreenBloc.removeCourse(course);
    var response = await user.save();
    
    if (response.error == null){  //SUCCESS
      savedCourses.remove(courseId);
      return true;
    }

    else return false; //SUCCESS
  }

  void updateBadge(bool increment){
      final ParseCloudFunction function = ParseCloudFunction('updateBadge');
      final Map<String, String> params = <String, String>{'increment': increment.toString()};
      function.execute(parameters: params);
  }

  bool userHasSavedCourse(String courseId) => savedCourses.indexOf(courseId) != -1;

  void setSavedCourseScreenBloc(SavedCourseScreenBloc _savedCourseScreenBloc){
    savedCourseScreenBloc = _savedCourseScreenBloc;
  }
  void getSavedCoursesCountFromServer() async{

    ParseUser user = await ParseUser.currentUser();
    if (user != null){

      var response = await ParseUser.getCurrentUserFromServer(user.sessionToken);
      if (response?.success ?? false) user = response.result;
    

      var notificationsBadge = user.get("notificationsBadge");
      if ( notificationsBadge != null && notificationsBadge < 0) notificationsBadge = 0;
      prefs.setInt('savedCoursesCount', notificationsBadge);
      _savedCoursesController.sink.add(notificationsBadge);

    }
  }
  void clearNotificationBadge() async{
    ParseUser user = await ParseUser.currentUser();
    prefs.setInt('savedCoursesCount', 0);
    if (user != null){
      user.set("notificationsBadge",0);
      user.save();
      _savedCoursesController.sink.add(0);
    }
  }
    @override
  void dispose(){
    _selectController.close();
    _savedCoursesController.close();
    _savedCourseStateController.close();
    _refreshCourseListController.close();
    _coursesController.close();
    _categoriesController.close();
    super.dispose();
  }
}