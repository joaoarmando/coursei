import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/search_course_bloc.dart';
import 'package:coursei/widgets/any_items_found.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/course_tile.dart';
import 'package:coursei/widgets/course_tile_no_internet.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/no_internet.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class SearchCourseScreen extends StatefulWidget {
  final SearchCourseBloc _searchCourseBloc = SearchCourseBloc();
  @override
  _SearchCourseScreenState createState() => _SearchCourseScreenState();
}

class _SearchCourseScreenState extends State<SearchCourseScreen> {
  GlobalKey<FormState> appbarKey;
  var focusNode = new FocusNode();


  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500)).then((a){
      FocusScope.of(context).requestFocus(focusNode);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: prefix0.secondaryColor,
        cursorColor: prefix0.secondaryColor,
       ),
      child: Scaffold(
        backgroundColor: prefix0.backgroundColor, 
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
          color: prefix0.greyBackground,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Material(
          type: MaterialType.transparency,
          child: TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.search,size: 30,color: prefix0.secondaryColor,),
              border: InputBorder.none,
              hintText: "O que quer aprender?",
              hintStyle: TextStyle(color: prefix0.hintColor, fontSize: 20)
            ),
            onChanged: (s){
              widget._searchCourseBloc.searchCourses(s);
            },
            onSubmitted: (s){
              widget._searchCourseBloc.searchCourses(s);
            },
            style: TextStyle(color:prefix0.primaryText, fontSize: 20, fontWeight: FontWeight.w600),   
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
            backgroundColor: prefix0.greyBackground,
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
    stream: widget._searchCourseBloc.outCourseListRefresh,
    initialData: ListController.IDLE,
    builder: (context, snapshot) {
      if (snapshot.data == ListController.LOADING)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(prefix0.secondaryColor),
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
                  color: prefix0.tertiaryText,
                  fontWeight: FontWeight.w600
                ),
              )
            ],
          );
      }
      else if (snapshot.data == ListController.NO_INTERNET_CONNECTION){
        return NoInternet(widget._searchCourseBloc.retryLoad);
      }
      else {
        return StreamBuilder<Map<String,dynamic>>(
            stream: widget._searchCourseBloc.outCourses,
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
                          if (snapshot.connectionState == ConnectionState.done) widget._searchCourseBloc.nextPage();
                          return Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(prefix0.secondaryColor), strokeWidth: 2),
                          );
                        }
                        else {
                          // na tem internet
                          return CourseTileNoInternet((){
                            widget._searchCourseBloc.tryAgainNextPage();
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
