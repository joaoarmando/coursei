import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/blocs/search_course_bloc.dart';
import 'package:coursei/repositories/courses_repository.dart';
import 'package:coursei/widgets/any_items_found.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/course_tile.dart';
import 'package:coursei/widgets/course_tile_no_internet.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/no_internet.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SearchCourseScreen extends StatefulWidget {
  @override
  _SearchCourseScreenState createState() => _SearchCourseScreenState();
}

class _SearchCourseScreenState extends State<SearchCourseScreen> {
  GlobalKey<FormState> appbarKey;
  var focusNode = new FocusNode();
  final _coursesRepository = BlocProvider.getDependency<CoursesRepository>();
  SearchCourseBloc _searchCourseBloc;

  @override
  void initState() {
    _searchCourseBloc = SearchCourseBloc(_coursesRepository);
    Future.delayed(Duration(milliseconds: 500)).then((a){
      FocusScope.of(context).requestFocus(focusNode);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: secondaryColor,
        cursorColor: secondaryColor,
       ),
      child: Scaffold(
        backgroundColor: backgroundColor, 
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              appbar(context),
              Expanded(
                child: coursesList(context),
              ),
            ],
          ),
        ),
        
      ),
    );
  }

  Widget searchBar(BuildContext context){
    return Hero(
      tag: "_backgroundsearch",
      child: Container(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: greyBackground,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.search,size: 30,color: secondaryColor,),
              border: InputBorder.none,
              hintText: "O que quer aprender?",
              hintStyle: TextStyle(color: hintColor, fontSize: 20)
            ),
            onChanged: _searchCourseBloc.onChangeSearchText,
            onSubmitted: _searchCourseBloc.onChangeSearchText,
            style: TextStyle(color:primaryText, fontSize: 20, fontWeight: FontWeight.w600),   
          ),
        ),
      ),
    );
  }
  Widget appbar(BuildContext context){
    return CustomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          AppBarButton(
            icon: Icons.close,
            backgroundColor: greyBackground,
            function: () async {
              FocusScope.of(context).unfocus();
              if (MediaQuery.of(context).viewInsets.bottom > 0)
                await Future.delayed(Duration(milliseconds: 100));
              
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: searchBar(context)
          ),
        ],
      ),
    );
  }
  Widget coursesList(BuildContext context){

  return StreamBuilder<ListController>(
    stream: _searchCourseBloc.outCourseListRefresh,
    initialData: ListController.IDLE,
    builder: (context, snapshot) {
      if (snapshot.data == ListController.LOADING)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(secondaryColor),
              strokeWidth: 2
            )
          );
      else if (snapshot.data == ListController.IDLE){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Procure por alguma coisa...",
                style: TextStyle(
                  fontSize: 18,
                  color: tertiaryText,
                  fontWeight: FontWeight.w600
                ),
              )
            ],
          );
      }
      else if (snapshot.data == ListController.NO_INTERNET_CONNECTION){
        return NoInternet(_searchCourseBloc.retryLoad);
      }
      else {
        return StreamBuilder<Map<String,dynamic>>(
            stream: _searchCourseBloc.outCourses,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              else if (snapshot.data["courses"].length == 0) {
                return Center(
                  child: SingleChildScrollView(
                    child:  AnyItemsFound("Ainda não temos nenhum curso que corresponda a sua pesquisa"),
                  ),
                );
              }      
              else return ListView.builder(
                itemCount: snapshot.data["courses"].length + 1,
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
                          if (snapshot.connectionState == ConnectionState.done) _searchCourseBloc.nextPage();
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
                            _searchCourseBloc.tryAgainNextPage();
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
          

      
    }
  );

}
}
