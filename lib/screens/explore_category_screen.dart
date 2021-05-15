import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/blocs/explore_category_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/interfaces/courses_repository_interface.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/course_list.dart';
import 'package:flutter/material.dart';


class ExploreCategoryScreen extends StatelessWidget {
  final CategoryData category;
  ExploreCategoryScreen(this.category);
  @override
  Widget build(BuildContext context) {

  final ICoursesRepositroy repository = BlocProvider.getDependency<ICoursesRepositroy>();
  final ExploreCategoryBloc categoryBloc = ExploreCategoryBloc(category.categoryId, repository);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            buildAppBar(context),
            Expanded(
              child: coursesList(categoryBloc)
            )
          ],
        ),
      ),
    );
  }
  Widget coursesList(ExploreCategoryBloc categoryBloc){
    return CourseList(
      outCourseListRefresh: categoryBloc.outCourseListRefresh,
      retryLoad: categoryBloc.retryLoad,
      outCourses: categoryBloc.outCourses,
      nextPage: categoryBloc.nextPage,
      tryAgainNextPage: categoryBloc.tryAgainNextPage,
    );  

  }

   Widget buildAppBar(BuildContext context){
    return CustomAppBar(
      child: Row(
        children: <Widget>[
          AppBarButton(
            icon: Icons.close,
            backgroundColor: greyBackground,
            function: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Text("${category.categoryName}",
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 21
            ),
          )
        ],
      ),
    );
  }
}
