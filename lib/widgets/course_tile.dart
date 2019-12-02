import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/screens/course_details_screen.dart';
import 'package:coursei/utils.dart';
import 'package:flutter/material.dart';

class CourseTile extends StatelessWidget {
  final ignorePadding;
  final CourseData course;
  CourseTile({@required this.course, this.ignorePadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      margin: ignorePadding == null ? const EdgeInsets.fromLTRB(12,6,12,6) : const EdgeInsets.all(0) ,
      decoration: BoxDecoration(
        color: greyBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Hero(
                tag: "thumbnail${course.objectId}",
                child: CachedNetworkImage(
                  imageUrl: course.thumbnail ?? "",
                  imageBuilder: (context, imageProvider) => Container(
                    width: 140,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: 140,
                    height: 120,
                    child: Container(
                      width:20, 
                      height:20, 
                      alignment: Alignment.center, 
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 1,)
                    )
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal:12),
                  child: Column(
                    children: <Widget>[
                      Text(course.title ?? "",
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text((course.price == null ? "" 
                              : course.price == 0 ? "Grátis" : "R\$:${course.price.toString().replaceAll(".", ",")}" ),
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              course.rate != null ? Row(
                                children: <Widget>[
                                  Text("${course.rate ?? ""}",
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  Icon(Icons.star, color: secondaryColor, size: 20,)
                                ],
                              ) : Container()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              )
            ],
          ),
          Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              splashColor: primarySplashColor,
              onTap: (){
                sendClickCourse(course);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CourseDetailsScreen(course),
                      settings: RouteSettings(name: "CourseDetailsScreen")
                    ),
                  );
              },
              
            ),
          )
        ],
      ),
    );
  }
}