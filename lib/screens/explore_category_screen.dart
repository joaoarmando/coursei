import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/explore_category_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/course_list.dart';
import 'package:flutter/material.dart';


class ExploreCategoryScreen extends StatefulWidget {

  final CategoryData category;
  final  categoryBloc = ExploreCategoryBloc();
  ExploreCategoryScreen(this.category);

  @override
  _ExploreCategoryScreen createState() => _ExploreCategoryScreen();
}

class _ExploreCategoryScreen extends State<ExploreCategoryScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            buildAppBar(context),
            Expanded(
              child: coursesList(context)
            )
          ],
        ),
      ),
    );
  }

   Widget coursesList(BuildContext context){
    widget.categoryBloc.selectCategory(widget.category.categoryId);
    return CourseList(
      outCourseListRefresh: widget.categoryBloc.outCourseListRefresh,
      retryLoad: widget.categoryBloc.retryLoad,
      outCourses: widget.categoryBloc.outCourses,
      nextPage: widget.categoryBloc.nextPage,
      tryAgainNextPage: widget.categoryBloc.tryAgainNextPage,
    );
   /* return StreamBuilder<LoadingCoursesState>(
      stream: widget.categoryBloc.outCourseListRefresh,
      initialData: LoadingCoursesState.IDLE,
      builder: (context, snapshot) {
        if (snapshot.data == LoadingCoursesState.NO_INTERNET_CONNECTION){

          return NoInternet(widget.categoryBloc.retryLoad);
          
        }
        else if (snapshot.data == LoadingCoursesState.LOADING)
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
        else   
          return StreamBuilder<Map<String,dynamic>>(
            stream: widget.categoryBloc.outCourses,
            builder: (context, snapshot) {
              
              if (snapshot.data == null) return Container();
              var itemCount = snapshot.data["courses"].length + 1;

              return ListView.builder(
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
                          if (snapshot.connectionState == ConnectionState.done) widget.categoryBloc.nextPage();
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
                            widget.categoryBloc.tryAgainNextPage();
                          });
                        }
                      },
                    );
                    
                  }
                  else return Container();
                },
              );
            }
          );
      }
    ); */
    

  }

   Widget buildAppBar(BuildContext context){
    return CustomAppBar(
      child: Row(
        children: <Widget>[
          AppBarButton(
            icon: Icons.close,
            backgroundColor: prefix0.greyBackground,
            function: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Text("${widget.category.categoryName}",
            style: TextStyle(
              color: prefix0.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 21
            ),
          )
        ],
      ),
    );
  }

  
 
 
  
}