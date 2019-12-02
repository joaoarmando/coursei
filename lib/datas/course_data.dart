import 'package:parse_server_sdk/parse_server_sdk.dart';

class CourseData{
  String objectId;
  String title;
  String description;
  String thumbnail;
  String url;
  double contentLength;
  double rate;
  double subscribers;
  double price;



  CourseData.fromParseObject(ParseObject course){
    objectId = course.objectId;
    title = course.get("title");
    description = course.get("description");
    thumbnail = course.get("thumbnail");
    url = course.get("url");
    if (course.get("contentLength") != null)  contentLength = course.get("contentLength") + 0.0;
    if (course.get("rate") != null)  rate = course.get("rate") + 0.0;
    if (course.get("subscribers") != null)  subscribers = course.get("subscribers") + 0.0;
    if (course.get("price") != null)  price = course.get("price") + 0.0;
  
  }

  CourseData.fromMap(Map<String,dynamic> course){
    objectId = course["objectId"];
    title = course["title"];
    description = course["description"];
    thumbnail = course["thumbnail"];
    url = course["url"];
    if (course["contentLength"] != null)  contentLength = course["contentLength"] + 0.0;
    if (course["rate"] != null)  rate = course["rate"] + 0.0;
    if (course["subscribers"] != null)  subscribers = course["subscribers"] + 0.0;
    if (course["price"] != null)  price = course["price"] + 0.0;
  }

  toMap(CourseData course){
    Map<String,dynamic> data = {
      "objectId":course.objectId,
      "title":course.title,
      "description":course.description,
      "thumbnail":course.thumbnail,
      "url":course.url,
      "contentLength":course.contentLength,
      "rate":course.rate,
      "subscribers":course.subscribers,
      "price":course.thumbnail,
    };
    return data;

  }
  

}