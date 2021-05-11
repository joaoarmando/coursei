
import 'package:coursei/widgets/course_tile.dart';
import 'package:coursei/widgets/no_internet.dart';
import 'package:flutter/material.dart';
import '../appColors.dart';
import '../utils.dart';
import 'course_tile_no_internet.dart';

class CourseList extends StatefulWidget {
  final Stream outCourseListRefresh;
  final Function retryLoad;
  final Stream outCourses;
  final Function nextPage;
  final Function tryAgainNextPage;

  CourseList({@required this.outCourseListRefresh, @required this.retryLoad, 
    @required this.outCourses, this.nextPage, this.tryAgainNextPage});

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<Offset> _offsetFloat; 
  Animation<double> opacityTween;
  Future<bool> getInternetConnection;
 
 

  @override
  initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
     opacityTween = Tween<double>(begin: 0.0,end: 1.0).animate(_controller);
    _offsetFloat = Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
        .animate(_controller);

    _offsetFloat.addListener((){
      setState((){});
    }); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoadingCoursesState>(
      stream: widget.outCourseListRefresh,
      initialData: LoadingCoursesState.IDLE,
      builder: (context, snapshot) {
        if (snapshot.data == LoadingCoursesState.NO_INTERNET_CONNECTION){

          return NoInternet(widget.retryLoad);
          
        }
        else if (snapshot.data == LoadingCoursesState.LOADING)
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
        else   
          return StreamBuilder<Map<String,dynamic>>(
            stream: widget.outCourses,
            builder: (context, snapshot) {
              
              if (snapshot.data == null) return Container();
              var itemCount = snapshot.data["courses"].length + 1;
                if (snapshot.data["canAnimate"]) _controller.forward();

                return Opacity(
                  opacity: opacityTween.value,
                  child: SlideTransition(
                    position: _offsetFloat,
                    child:  ListView.builder(
                    itemCount: itemCount,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      if (index < snapshot.data["courses"].length){
                        return CourseTile(
                          course: snapshot.data["courses"][index],
                        );
                      }
                      else if (snapshot.data["hasMore"]){
                        return FutureBuilder(
                          future: hasInternetConnection(true),
                          builder: (context, snapshot) {

                            bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                            if (!isLoading && snapshot.data != null) isLoading = snapshot.data;
                            if (isLoading){
                              //tem net
                              if (snapshot.connectionState == ConnectionState.done) widget.nextPage();
                              return Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor), strokeWidth: 2),
                              );
                            }
                            else {
                              // na tem internet
                              return CourseTileNoInternet((){
                                widget.tryAgainNextPage();
                              });
                            }
                          },
                        );
                        
                      }
                      else return Container();
                    },
                  ),
              ),
                ); 

            }
          );
      }
    );
  }
}