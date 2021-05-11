import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';

class CourseDetailsBloc extends BlocBase {

  void goToCourse(CourseData course) async {

    String url = course.url;

    // if (!alreadyStarted){
    //     alreadyStarted = true;
    //     sendClickStartCourse(course);
    // }

    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  @override
  void dispose(){
    super.dispose();
  }
}