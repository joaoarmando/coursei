import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/add_course_bloc.dart';
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/presentation/coursei_icons_icons.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/course_tile.dart';
import 'package:coursei/widgets/custom_text_field.dart';
import 'package:coursei/widgets/error_text.dart';
import 'package:coursei/widgets/login_options.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../appColors.dart';

class AddCourseScreen extends StatefulWidget {
  final _addCourseBloc = AddCourseBloc();
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  bool bottomSheetIsOpen = false;
  bool ignoreTimer = false;
  bool screnClosed = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState(){
    super.initState();

    Future.delayed(Duration(milliseconds: 50)).then((a){

        widget._addCourseBloc.outPriceButtonState.listen((state) async{

          if (state == PriceButtonState.NEED_LOGIN) showDialogSignUp();
          
          else if (state == PriceButtonState.SUCCESSFULLY) {
            bottomSheetIsOpen = true;
            ignoreTimer = false;
            await showBottomSheetSuccess();
            ignoreTimer = true;
            if (!screnClosed){
              Navigator.pop(context);
            }
            
          }
          else if (state == PriceButtonState.NO_INTERNET_CONNECTION){
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Sem conexão com a internet",
                textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0, fontWeight: 
                FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Colors.red,)
            );
          }
          
        });

    });
    
    
  }

  showDialogSignUp() async{

    await Future.delayed(Duration(milliseconds: 50));
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
                child: LoginOptions(_userBloc),
              ),
            ],
          ),
        ),
        
      );
    },
  ); 
  }
  showBottomSheetSuccess(){
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )
        ),
        backgroundColor: backgroundColor,
        builder: (builder){
          return new Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 180,
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  child: FlareActor("assets/check_animation.flr",
                    alignment:Alignment.center,
                    fit:BoxFit.contain, 
                    animation: "check",
                    callback: (string) async{
                      await Future.delayed(Duration(milliseconds: 2000));

                      if (bottomSheetIsOpen && context != null) Navigator.pop(context); // FECHA BOTTOMSHEET
                      
                      if (!ignoreTimer && context != null) Navigator.pop(context); //FECHA ACTIVITY

                      if (!ignoreTimer && bottomSheetIsOpen) screnClosed = true;

                    },
                  )
                ),
                Text("Curso enviado com sucesso!",
                  style: TextStyle(color: secondaryText, fontSize: 21, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text("Tentaremos adicionar este curso o mais breve possível!",
                  style: TextStyle(color: tertiaryText, fontSize: 15,),
                ),
              ],
            ),
          );
        }
    );
      
  }
  @override
  Widget build(BuildContext context) {
 
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: secondaryColor,
        cursorColor: secondaryColor,
       ),
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  children: <Widget>[
                    buildAppBar(context),
                    SizedBox(height: 15,),
                    CustomTextField(
                      hint: "Link do curso",
                      obscure: false,
                      changed: (s){
                        widget._addCourseBloc.validateLink(s);
                      },
                      height: 60,
                      icon: Icon(CourseiIcons.ic_link),
                    ),
                    ErrorText(widget._addCourseBloc.outLink),
                    SizedBox(height: 15),
                    Text("Este curso é pago ou gratuito?",
                      style: TextStyle(
                        color: secondaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    priceButton(context),
                    SizedBox(height: 5),
                    Text("Se gratuito por tempo limitado selecione \"Pago\"",
                      style: TextStyle(
                        color: tertiaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),

                    StreamBuilder<LinkPreviewState>(
                      stream: widget._addCourseBloc.outLinkPreviewState,
                      builder: (context, snapshot){

                        switch(snapshot.data){
                          case LinkPreviewState.IDLE:
                           return Container();
                          case LinkPreviewState.LOADING:
                            return loadingPreview(context);
                          case LinkPreviewState.SUCCESSFULLY:
                            return linkPreview();  
                          case LinkPreviewState.ERROR:
                            return linkPreview();  
                          default:
                            return Container();   
                        }
                      },
                    ),
                    SizedBox(height: 70),
                    
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: addCourseButton(),
              )
            ],
          ),
        ),

      ),
    );
  }

  Widget loadingPreview(BuildContext context){
    return containerLinkPreview(
      context: context,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2,),
            SizedBox(height: 5),
            Text("Buscando prévia do link...",
              style: TextStyle(
                color: tertiaryText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            )
          ],
        ),
      )

    );
  }

  Widget linkPreview(){
    return IgnorePointer(
      ignoring: true,
      child: StreamBuilder<CourseData>(
        stream: widget._addCourseBloc.outCourseData,
        builder: (context, snapshot) {
          return snapshot.data != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text("Prévia do link",
                  style: TextStyle(
                    color: secondaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              CourseTile(
                course: snapshot.data,
              ),
            ],
          ) : Container();
          
        }
      ),
    );
  }

  Widget linkPreviewFailed(){
   return containerLinkPreview(
      context: context,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              child: FlareActor("assets/error.flr",animation: "Error",),
            ),
            SizedBox(height: 5),
            Text("Opa, não conseguimos encontrar nenhuma prévia para este link",
              style: TextStyle(
                color: tertiaryText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      )

    );
  }

  Widget containerLinkPreview({BuildContext context,Widget child}){
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(12,6,12,6),
      decoration: BoxDecoration(
        color: greyBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget buildAppBar(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 15),
      height: 55,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Align(
            alignment:Alignment.centerLeft,
            child: AppBarButton(
              icon: Icons.close,
              backgroundColor: greyBackground,
              function: (){
              
                Navigator.pop(context);
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Adicionar curso",
              style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget priceButton(BuildContext context){
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: greyBackground,
          borderRadius: BorderRadius.circular(99)
        ),
        child: Stack(
          children: <Widget>[
            StreamBuilder<PriceState>(
              stream: widget._addCourseBloc.outPriceState,
              initialData: PriceState.FREE_COURSE,
              builder: (context, snapshot) {
                return AnimatedContainer(
                  width: MediaQuery.of(context).size.width * .8,
                  duration: Duration(milliseconds: 200),
                  alignment: snapshot.data == PriceState.FREE_COURSE ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(99)
                    )
                  ),
                  
                );
              }
            ),
            Row(
              children: <Widget>[
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: (){
                      widget._addCourseBloc.changePriceState(PriceState.FREE_COURSE);
                    },
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99)
                      ),
                      child: Text("Gratuito",
                        style: TextStyle(color: secondaryText,fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: (){
                      widget._addCourseBloc.changePriceState(PriceState.PAID_COURSE);
                    },
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99)
                      ),
                      child: Text("Pago",
                        style: TextStyle(color: secondaryText,fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],

        ),
      ),
    );
  }

  Widget addCourseButton(){
    return StreamBuilder<PriceButtonState>(
      stream: widget._addCourseBloc.outPriceButtonState,
      builder: (context, snapshot) {
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
                    color: snapshot.data == PriceButtonState.DISABLED ? Colors.grey : secondaryColor,
                    boxShadow:[
                      BoxShadow(
                        color: snapshot.data == PriceButtonState.DISABLED ? Colors.transparent : secondaryColor.withOpacity(.4),
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
                      onTap: snapshot.data == PriceButtonState.ENABLED || snapshot.data == PriceButtonState.NEED_LOGIN 
                      ? widget._addCourseBloc.sendCourse : null,
                      child: snapshot.data == PriceButtonState.DISABLED || snapshot.data ==  PriceButtonState.ENABLED ||
                      snapshot.data == PriceButtonState.NEED_LOGIN ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Enviar curso!",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          SizedBox(width: 10),
                        // Image.asset("assets/icons/ic_start_course.png",height: 30)
                        Icon(Icons.send,color: secondaryText, size: 30,)
                        ],
                      ): Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white),strokeWidth: 1)
                        ),
                    ),
                  ),
              ),
            ),
          );
      }
    );
  }
}