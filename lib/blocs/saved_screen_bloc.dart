import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/datas/pending_course.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedCourseScreenBloc extends BlocBase {

  final _refreshCourseListController = BehaviorSubject<bool>.seeded(true);
  final _savedCoursesController = BehaviorSubject<Map<String,dynamic>>();
  final _refreshSendedCourseListController = BehaviorSubject<bool>.seeded(true);
  final _sendedCoursesController = BehaviorSubject<Map<String,dynamic>>();


  Stream<Map<String,dynamic>> get outSavedCourses => _savedCoursesController.stream;
  Stream<bool> get outCourseListRefresh => _refreshCourseListController.stream;
  Stream<Map<String,dynamic>> get outSendedCourses => _sendedCoursesController.stream;
  Stream<bool> get outSendedCourseListRefresh => _refreshSendedCourseListController.stream;
  int removedPosition = -1;
  Map<String,dynamic> savedCourses = {
    "courses":[],
    "hasMore":false
  };
  Map<String,dynamic> sendedCourses = {
    "courses":[],
    "hasMore":false
  };
  SharedPreferences prefs;
  
  List<String> savedCoursesIds = [];
 
  


  void nextPageSavedCourses(){
    getSavedCourses(true);
  }

  void getSavedCourses(bool nextPage) async{
    if (!nextPage) _refreshCourseListController.sink.add(true);
    var queryBuilder = QueryBuilder(ParseObject('Courses'))..setLimit(10);

    queryBuilder.whereContainedIn("objectId", savedCoursesIds);
    queryBuilder.setLimit(10);
    if (nextPage) queryBuilder.setAmountToSkip(savedCourses["courses"].length);
    
    
    List<CourseData> courseList = [];
    
    var apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há cursos
        for (var course in apiResponse.result){
          courseList.add(CourseData.fromParseObject(course));
        }
      }
      
      bool hasMoreCourses = courseList.length > 9;


        savedCourses["courses"] += courseList;
        savedCourses["hasMore"] = hasMoreCourses;


      if(!nextPage) _refreshCourseListController.sink.add(false);
      _savedCoursesController.sink.add(savedCourses);

    }
    
    return null;    
  }
 
  void startSharedPreferences() async{
     prefs = await SharedPreferences.getInstance();
     getSavedCoursesFromServer();
  }

 

  void getSavedCoursesFromServer() async{
    ParseUser user = await ParseUser.currentUser();
    if (user != null){
      var _savedCourses = user.get("savedCourses");
      if (_savedCourses != null){
        savedCoursesIds = List<String>.from(_savedCourses);
      }
      getSavedCourses(false);
    }
    
  }



  void nextPageSendedCourses(){
    getSendedCourses(true);
  }
  void getSendedCourses(bool nextPage) async{

    
    if (!nextPage) _refreshCourseListController.sink.add(true);
    var queryBuilder = QueryBuilder(ParseObject('PendingCourses'))..setLimit(10);
    if (nextPage) queryBuilder.setAmountToSkip(sendedCourses["courses"].length);
    queryBuilder.includeObject(["course"]);
    
    
    List<PendingCourse> courseList = [];
    
    var apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há cursos
        for (var course in apiResponse.result){
          courseList.add(PendingCourse.fromParseObject(course));
        }
      }
      
      bool hasMoreCourses = courseList.length > 9;


        sendedCourses["courses"] += courseList;
        sendedCourses["hasMore"] = hasMoreCourses;


      if(!nextPage) _refreshSendedCourseListController.sink.add(false);
      _sendedCoursesController.sink.add(sendedCourses);

    }
    
    return null;    
  }
  void removeCourse(CourseData course){

    var index = getIndex(course.objectId);
    if ( index != -1){
        savedCourses["courses"].removeAt(index);
        removedPosition = index;
        _savedCoursesController.add(savedCourses);
    }
  }
  void addCourse(CourseData course){
     var index = getIndex(course.objectId);
    if (index == -1){
      savedCourses["courses"].insert(removedPosition,course);
      _savedCoursesController.add(savedCourses);
    }
  }

  int getIndex(String courseId){
    for (var i = 0;i < savedCourses["courses"].length; i ++) {
        if (savedCourses["courses"][i].objectId == courseId) return i;
    }
    return -1;
  }


  
    @override
  void dispose(){
    _savedCoursesController.close();
    _refreshCourseListController.close();
    _sendedCoursesController.close();
    _refreshSendedCourseListController.close();

    super.dispose();
  }
}