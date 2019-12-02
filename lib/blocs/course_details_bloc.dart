import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsBloc extends BlocBase {
  
  final _savedCourseStateController = BehaviorSubject<bool>();
  Stream<bool> get outSavedCoursesState => _savedCourseStateController.stream;
  HomeBloc _homeBloc;
 
 
  void setHomeBloc(HomeBloc homeBloc){
    _homeBloc = homeBloc;
  }
  
  void saveCourse(CourseData course) async{
    _savedCourseStateController.sink.add(true);
    var success = await _homeBloc.saveCourse(course);
    if (!success) _savedCourseStateController.sink.add(false);

  }
  void removeSavedCourse(CourseData course) async{
     _savedCourseStateController.sink.add(false);
    var success = await _homeBloc.removeSavedCourse(course);
    if (!success) _savedCourseStateController.sink.add(true);
   
  }
  void goToCourse(String url) async{

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  
  
    @override
  void dispose(){
    _savedCourseStateController.close();
    super.dispose();
  }
}