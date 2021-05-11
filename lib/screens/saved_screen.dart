import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/blocs/saved_screen_bloc.dart';
import 'package:coursei/datas/pending_course.dart';
import 'package:coursei/screens/user_account_screen.dart';
import 'package:coursei/widgets/any_items_found.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/course_tile.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import '../appColors.dart';
import 'package:timeago/timeago.dart' as timeago;


class SavedCoursesScreen extends StatefulWidget {
  @override
  _SavedCoursesScreenState createState() => _SavedCoursesScreenState();
}

class _SavedCoursesScreenState extends State<SavedCoursesScreen> {
  final _savedCourseBloc = SavedCourseScreenBloc();   
  @override
  void initState() {
    _savedCourseBloc.startSharedPreferences();
    _savedCourseBloc.getSendedCourses(false);
    timeago.setLocaleMessages('pt', timeago.PtBrMessages());
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(105),
              child: appbar(context),
            ),
            body: TabBarView(
              children: <Widget>[
                savedCourses(context),
                sendedCourses(context),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget appbar(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal:12,vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            offset: Offset(0,2),
            blurRadius: 2
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
         Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppBarButton(
                      icon: Icons.close,
                      iconColor: secondaryText,
                      backgroundColor: greyBackground,
                      function: (){
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text("Seus cursos",
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppBarButton(
                      icon: Icons.edit,
                      iconColor: secondaryText,
                      backgroundColor: greyBackground,
                      function: (){
                        final screen = UserAccountScreen();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                      },
                    ),
                  ],
                ),
               // SizedBox(height: 12),
                TabBar(
                  isScrollable: true,
                  indicatorColor: tertiaryText,
                  labelColor: tertiaryText,
                  labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
                  tabs: [
                    Tab(text: "Cursos salvos",),
                    Tab(text: "Cursos enviados"),
                  ],
                )
              ],
            )
          )
          ,
        ],
      ),
    );
  }

  Widget savedCourses(BuildContext context){
    return StreamBuilder<bool>(
        stream:_savedCourseBloc.outCourseListRefresh,
        initialData: true,
        builder: (context, snapshot){
          if (!snapshot.data){
            return StreamBuilder(
              stream: _savedCourseBloc.outSavedCourses,
              builder: (context, snapshot){
                if (snapshot.data == null) return Container();
                else if (snapshot.data["courses"].length > 0){
                  return ListView.builder(
                    itemCount: snapshot.data["courses"].length + 1,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      if (index < snapshot.data["courses"].length){
                        return CourseTile(
                        course: snapshot.data["courses"][index],
                      );
                      }
                      else if (snapshot.data["hasMore"]){
                        _savedCourseBloc.nextPageSavedCourses();
                        return Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor), strokeWidth: 2),
                        );
                      }
                      else return Container();
                    },
                  );
                }
                else
                  return AnyItemsFound("Você ainda não enviou nenhum curso para o aplicativo.");
                
              },
            );
          }
          else return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
        },
      );
  }
  Widget sendedCourses(BuildContext context){
    return StreamBuilder<bool>(
        stream:_savedCourseBloc.outSendedCourseListRefresh,
        initialData: true,
        builder: (context, snapshot){
          if (!snapshot.data){
            return StreamBuilder(
              stream: _savedCourseBloc.outSendedCourses,
              builder: (context, snapshot){
                if (snapshot.data == null) return Container();
                else if (snapshot.data["courses"].length > 0){
                  return ListView.builder(
                    itemCount: snapshot.data["courses"].length + 1,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      if (index < snapshot.data["courses"].length){
                        PendingCourse course = snapshot.data["courses"][index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.2),
                                offset: Offset(0,2),
                                blurRadius: 2
                              )
                            ],
                            color: backgroundColor, 
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              IgnorePointer(
                                ignoring: true,
                                child: CourseTile(
                                  course: course.courseData,
                                  ignorePadding: false
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text("Enviado: ${timeago.format(course.createdAt,locale: 'pt')}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryText
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12, right: 12,bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      width: 40,
                                      child:  !course.added ? FlareActor("assets/waiting.flr",animation: "animating")
                                      : FlareActor("assets/check_animation.flr") ,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(!course.added ? "Aguardando aprovação do administrador" : "Curso adicionado",
                                        style: TextStyle(
                                          color: tertiaryText,
                                          fontSize: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            
                            ],
                          ),
                        );
                      }
                      else if (snapshot.data["hasMore"]){
                        _savedCourseBloc.nextPageSavedCourses();
                        return Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor), strokeWidth: 2),
                        );
                      }
                      else return Container();
                    },
                  );
                }
                else
                  return AnyItemsFound("Parece que você ainda não salvou nenhum curso para ver mais tarde.");
                
              },
            );
          }
          else return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
        },
      );
  }
}