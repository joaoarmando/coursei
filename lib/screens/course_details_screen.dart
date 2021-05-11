import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/blocs/courses_details_bloc.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/presentation/coursei_icons_icons.dart';
import 'package:coursei/screens/report_problem_screen.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/login_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:share/share.dart';

import 'new_account_screen.dart';


class CourseDetailsScreen extends StatefulWidget {
  final CourseData course;
  CourseDetailsScreen(this.course);

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>  with SingleTickerProviderStateMixin{
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  final CourseDetailsBloc _courseDetailsBloc = CourseDetailsBloc();
  AnimationController _controller;
  Animation<Offset> _offsetFloat; 
  Animation<double> opacityTween;

  @override
  void initState(){
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
     opacityTween = Tween<double>(begin: 0.0,end: 1.0).animate(_controller);
    _offsetFloat = Tween<Offset>(begin: Offset(0.0, 0.2), end: Offset.zero)
        .animate(_controller);

    opacityTween.addListener((){
      setState((){});
    }); 
    Future.delayed(Duration(milliseconds:10)).then((a){
      _controller.forward();
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            //IMAGEM
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Hero(
                tag: "thumbnail${widget.course.objectId}",
                child: CachedNetworkImage(
                  imageUrl: widget.course.thumbnail ,
                  imageBuilder: (context, imageProvider) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Container(
                      width:20, 
                      height:20, 
                      alignment: Alignment.center, 
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 1,)
                    )
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              )
            ),
            //BT VOLTAR
            Positioned(
              top: 12,
              left: 12,
              child: Opacity(
                opacity: opacityTween.value,
                child: AppBarButton(
                  icon: Icons.close,
                  function: () async{
                    await Future.delayed(Duration(milliseconds: 20));
                    Navigator.pop(context);
                  },
                  
                ),
              ),
            ),
            //BT SALVAR
            Positioned(
              top: 12,
              right: 12,
              child: Opacity(
                opacity: opacityTween.value,
                child: AppBarButton(
                  icon: CourseiIcons.ic_menu_vertical,
                  iconSize: 30,     
                  function: (){
                    showDialogMoreOptions();
                  },
                ),
              ),
            ),
            // INFO CURSO
            Positioned.fill(
              top: 250,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _offsetFloat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //SHEET CURSO
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                        ),
                        padding: EdgeInsets.only(top: 12),
                        child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical:0, horizontal: 12),
                                child: Text(widget.course.title,
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18
                                  ), 
                                ),
                              ),
                              SizedBox(height: 15),
                              _courseCardList(),
                              SizedBox(height: 15),
                              Expanded(
                                child: Padding(
                                 padding: const EdgeInsets.symmetric(vertical:0, horizontal: 12),
                                  child: ListView(
                                    children: <Widget>[
                                      Text("Descrição",
                                        style: TextStyle(
                                          color: secondaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(widget.course.description,
                                        style: TextStyle(
                                          color: tertiaryText,
                                          fontSize: 15
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _btSaveCourse(),
                                  _goToCourse()
                                ],
                              )
                            ],
                          ),
                      ),
                    ),
                 
                  ],
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _goToCourse(){
    return Container(
        height: 55,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30))
            ),
          elevation: 6.0,
          child: Container(
            height: 55,
            width: MediaQuery.of(context).size.width * .6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
              color: secondaryColor,
              boxShadow:[
                BoxShadow(
                  color: secondaryColor.withOpacity(.4),
                  offset: Offset(10, 0),
                  blurRadius: 10.0)
              ]
            ),
            child: Material(
              type: MaterialType.transparency,
              elevation: 6.0,
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
                splashColor: secondarySplashColor,
                onTap: () {
                   _courseDetailsBloc.goToCourse(widget.course);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Começar agora!",
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(CourseiIcons.ic_start_course,size: 25),
                    
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
  Widget _courseCardList(){
    String price = widget.course.price == 0 ? "Grátis" : "R\$:${widget.course.price.toString().replaceAll(".", ",")}";
    String subscribers = "${NumberFormat.compact().format(widget.course.subscribers)}";
    return Container(
      height: 70,
      alignment: Alignment.center,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          _courseCard("${convertMinutesToHours(widget.course.contentLength.toInt())} Horas",CourseiIcons.ic_playlist),
          _courseCard("${widget.course.rate}",CourseiIcons.ic_rate),
          _courseCard("$subscribers",CourseiIcons.ic_people),
          _courseCard("$price",CourseiIcons.ic_currency),
        ],  
      ),
    );
  }
  Widget _courseCard(String text, IconData icon){
    return Container(
      width: 75,
      margin:EdgeInsets.symmetric(vertical: 0,horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: greyBackground
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Image.asset(imagePath,height: 30,width: 30,),
          Icon(icon,size: 30, color: secondaryColor),
          SizedBox(height: 3),
          Text(text,
            style: TextStyle(
              color: tertiaryText,
              fontWeight: FontWeight.w700,
              fontSize: 13
            )
          )
        ],
      ),

    );
  }
  String convertMinutesToHours(int value){
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    return '${hour.toString()}.${minutes.toString()}';
  }
  Widget _btSaveCourse(){
    return Container(
      height: 55,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(999))
          ),
        elevation: 6.0,
        child: Container(
          height: 55,
          width:100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(999)),
            color: secondaryColor,
            boxShadow:[
              BoxShadow(
                color: secondaryColor.withOpacity(.4),
                offset: Offset(5, 0),
                blurRadius: 10.0)
            ]
          ),
          child: Material(
            type: MaterialType.transparency,
            elevation: 6.0,
            color: Colors.transparent,
            child: StreamBuilder<bool>(
              stream: _userBloc.outSavedCoursesState,
              initialData: _userBloc.userHasSavedCourse(widget.course.objectId),
              builder: (context, snapshot) {
                bool isSaved = snapshot.data; 
                return InkWell(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(999)),
                  splashColor: secondarySplashColor,
                  onTap: ()  async{
                    if (await ParseUser.currentUser() != null ) {
                      if (!isSaved)
                        _userBloc.saveCourse(widget.course);
                      else  
                        _userBloc.removeSavedCourse(widget.course);
                    }else {
                      showDialogSignUp();
                    }

                       

                  },
                  child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: secondaryText, 
                        size: 35
                      ),
                  ),
                );
              }
            ),
          ),
      ),
    ),
  );
  }
  

  showDialogMoreOptions() async{
    return await showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(12,12,12,12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ) ,
        content: Theme(
          data: Theme.of(context).copyWith(
            primaryColor: secondaryColor,
            cursorColor: secondaryColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,

                ),
                child: buildDialogMoreOptions(),
              ),
            ],
          ),
        ),
        
      );
    },
  ); 
  }
  Widget buildDialogMoreOptions(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Mais opções",
          style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 15),
        _buildDialogButton(
          color:secondaryColor,
          text:"Compartilhar curso",
          function:() async{
            await Future.delayed(Duration(milliseconds: 150));
             Navigator.pop(context);
             Share.share("O curso \"${widget.course.title}\" está de graça! ${widget.course.url} \nDescubra esse e outras centenas de cursos gratuitos baixando o aplicativo \"Coursei\" na Play Store.");
          },
        ),
        SizedBox(height: 15),
        _buildDialogButton(
          color:Colors.red,
          text:"Reportar um problema",
          function: () async{
             await Future.delayed(Duration(milliseconds: 150));
             Navigator.pop(context);
             Navigator.push(context, MaterialPageRoute(builder: (context) => ReportProblemScreen(widget.course.objectId)));

          }
        ),
        SizedBox(height: 15),
      ],
    );
  }
  Widget _buildDialogButton({@required Color color, String text, Function function}){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
              ),
            elevation: 0.0,
            child: Container(
              height: 55,
              width: MediaQuery.of(context).size.width * .7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor,
                border: Border.all(color: color, width: 1)
              ),
              child: Material(
                type: MaterialType.transparency,
                elevation: 0.0,
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: primarySplashColor,
                  onTap: function,
                  child:  Center(
                    child: Text(text,
                      style: TextStyle(
                        color: color == secondaryColor ? secondaryText : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w700
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ),
    ),
        ],
      );
  }
   showDialogSignUp() async{
    return await showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
        final _loginBloc = LoginBloc();
      _loginBloc.setUserBloc(_userBloc);
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(12,12,12,12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ) ,
        content: Theme(
          data: Theme.of(context).copyWith(
            primaryColor: secondaryColor,
            cursorColor: secondaryColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,

                ),
                child: StreamBuilder<DialogState>(
                  stream: _userBloc.outDialogState,
                  initialData: DialogState.DIALOG_OPTIONS,
                  builder: (context, snapshot) {
                    switch(snapshot.data){
                      case DialogState.DIALOG_OPTIONS:
                        return buildDialogLoginOptions();
                      break;
                      case DialogState.LOGIN_STATE:
                        return LoginDialog();
                      break;  
                      default:
                      return Container();
                    }
                  }
                ),
              ),
            ],
          ),
        ),
        
      );
    },
  ); 
  }

  Widget buildDialogLoginOptions(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        "Fazer login",
        style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 15),
      Text("Você precisa fazer login para ver seus cursos salvos",
        style: TextStyle(color: secondaryText, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 15),
      _buildDialogLoginButton(
        isPrimaryButton:true,
        text:"Já tenho uma conta",
        function: _userBloc.goToSignIn,
      ),
      SizedBox(height: 15),
      _buildDialogLoginButton(
        isPrimaryButton:false,
        text:"Criar uma conta",
        function: () async{
            await Future.delayed(Duration(milliseconds: 150));
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewAccountScreen()));

        }
      ),
      
  
    ],
  );
}

Widget _buildDialogLoginButton({@required isPrimaryButton, String text, Function function}){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
              ),
            elevation: 0.0,
            child: Container(
              height: 55,
              width: MediaQuery.of(context).size.width * .7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isPrimaryButton ? secondaryColor : backgroundColor,
                border: Border.all(color: secondaryColor, width: 1)
              ),
              child: Material(
                type: MaterialType.transparency,
                elevation: 0.0,
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: secondarySplashColor,
                  onTap: function,
                  child:  Center(
                    child: Text(text,
                      style: TextStyle(
                        color: isPrimaryButton ? primaryText : secondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ),
    ),
        ],
      );
  }
 

}
