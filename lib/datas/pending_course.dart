import 'package:coursei/datas/course_data.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class PendingCourse{
  String objectId;
  String courseId;
  bool added;
  DateTime createdAt;
  CourseData courseData;
 


  PendingCourse.fromParseObject(ParseObject course){

    objectId = course.objectId;
    createdAt = course.createdAt;
    courseId = course.get("courseId");
    added = course.get("added");
    if (course.get("course") != null)  courseData = CourseData.fromParseObject(course.get("course"));
    else courseData = CourseData.fromParseObject(course);
  
  }

  

}