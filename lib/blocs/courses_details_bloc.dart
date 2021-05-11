import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

class CourseDetailsBloc extends BlocBase {

  bool alreadyStarted = false;

  void goToCourse(CourseData course) async {

    String url = course.url;
    // avoid many calls to analytics
    if (!alreadyStarted){
        alreadyStarted = true;
        sendClickStartCourse(course);
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose(){
    super.dispose();
  }
}