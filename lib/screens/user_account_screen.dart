import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/user_account.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/error_text.dart';
import 'package:flutter/material.dart';

import '../appColors.dart';

class UserAccountScreen extends StatefulWidget {
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  final _userAccountBloc = UserAccountBloc();
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  Timer timerUserName;
  Timer timerEmail;
  Timer timerPassword;
  bool screnClosed = false;
  @override
  void initState() {
    _userAccountBloc.getUser();
    _userAccountBloc.setUserBloc(_userBloc);
    _userAccountBloc.outName.listen((data) {
        _userAccountBloc.validateInfo();
      }, onError: (error) {
        _userAccountBloc.validateInfo();
      });
    _userAccountBloc.outEmail.listen((data) {
        _userAccountBloc.validateInfo();
      }, onError: (error) {
        _userAccountBloc.validateInfo();
      });
    _userAccountBloc.outPassword.listen((data) {
        _userAccountBloc.validateInfo();
      }, onError: (error) {
        _userAccountBloc.validateInfo();
      });
    _userAccountBloc.outButton.listen((a){
      if (a == SaveState.SUCCSSEFULLY){
        Navigator.pop(context);
      }
    });
    _userAccountBloc.outLogoutState.listen((a){
      if (a == LogoutState.LOGOUT_SUCCESSFULLY){
         if (!screnClosed){
            Navigator.pop(context);
          }
        Navigator.pop(context);
        Navigator.pop(context);
      }
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
        backgroundColor: prefix0.backgroundColor,
        body: SafeArea(
          child: StreamBuilder<bool>(
            stream: _userAccountBloc.outLoading,
            initialData: true,
            builder: (context, snapshot) {
              if (snapshot.data) {
                return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
              }
              else {
                return Stack(
                  children: <Widget>[
                    ListView(
                      children: <Widget>[
                        appbar(context),
                        SizedBox(height: 24),
                        Image.asset("assets/icons/ic_user_male.png", height: 100, width: 100),
                        SizedBox(height: 12),
                        buildTextInput(
                          hint: "Nome",
                          stream: _userAccountBloc.outName,
                          changed: (s){
                            if (timerUserName != null) timerUserName.cancel();
                            timerUserName = new Timer(Duration(milliseconds: 500), () => _userAccountBloc.changeName(s));       
                          },
                          obscure: false,
                          keyboardType: TextInputType.text,
                          icon: Icons.person
                        ),
                        SizedBox(height: 12),
                        buildTextInput(
                          hint: "Email",
                          stream: _userAccountBloc.outEmail,
                          changed: (s){
                            if (timerEmail != null) timerEmail.cancel();
                            timerEmail = new Timer(Duration(milliseconds: 500), () => _userAccountBloc.changeEmail(s));
                          },
                          obscure: false,
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email
                        ),
                        SizedBox(height: 12),
                        buildTextInput(
                          hint: "Senha",
                          stream: _userAccountBloc.outPassword,
                          changed: (s){
                            if (timerPassword != null) timerPassword.cancel();
                            timerPassword = new Timer(Duration(milliseconds: 500), () => _userAccountBloc.changePassword(s));
                          },
                          obscure: true,
                          keyboardType: TextInputType.text,
                          icon: Icons.lock
                        ),

                        SizedBox(height: 25),
                        FlatButton(
                          child: Text("Deletar minha conta",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          onPressed: () async{
                            screnClosed = false;
                            await showDialogDeleteAccount();
                            screnClosed = true;
                          },
                        ),
                        
                      ],
                    ),
                     Positioned(
                       bottom: 0,
                       right: 0,
                       child: saveChanges(_userAccountBloc),
                     )
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget appbar(BuildContext context){
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
          Expanded(
            child: Text("Editar perfil",
              style: TextStyle(
                color: prefix0.primaryText,
                fontSize: 21,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          AppBarButton(
            icon: Icons.exit_to_app,
            backgroundColor: prefix0.greyBackground,
            function: () async{
              screnClosed = false;
              await showDialogLogout();
              screnClosed = true;
            }
          ),
        ],
      )
    );
  }

  showDialogLogout() async{
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
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text("Sair da conta",
                    style: TextStyle(
                      fontSize: 21,
                      color: prefix0.primaryText,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 12),
                  StreamBuilder<LogoutState>(
                    stream: _userAccountBloc.outLogoutState,
                    builder: (context, snapshot) {
                      if (snapshot.data == LogoutState.IDLE){
                        return Column(
                          children: <Widget>[
                            Text("Tem certeza que deseja sair desta conta?",
                              style: TextStyle(
                                fontSize: 18,
                                color: prefix0.primaryText,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                  child: Text("Cancelar",
                                    style: TextStyle(color: primaryText,fontWeight: FontWeight.w700, fontSize: 21),
                                  ),
                                  onPressed: (){
                                  
                                    Navigator.pop(context);
                                  },
                                ),
                                SizedBox(width: 12),
                                FlatButton(
                                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                    child: Text("Sim",
                                      style: TextStyle(color: primaryText,fontWeight: FontWeight.w700, fontSize: 21),
                                    ),
                                    onPressed: _userAccountBloc.logout,
                                  )
                              ],
                            )
                          ],
                        );
                      }
                      else if (snapshot.data == LogoutState.LOADING){
                         return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2),
                            ),
                            SizedBox(height: 12),
                            Text("Saindo...",
                              style: TextStyle(
                                fontSize: 18,
                                color: prefix0.primaryText,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }
                      else
                      return Container();
                      
                    }
                  )
                ],
              ),
            )
          ),
          
        );
      },
    ); 
  }
  
  showDialogDeleteAccount() async{
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
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text("Excluir conta",
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 12),
                  StreamBuilder<LogoutState>(
                    stream: _userAccountBloc.outLogoutState,
                    builder: (context, snapshot) {
                      if (snapshot.data == LogoutState.IDLE){
                        return Column(
                          children: <Widget>[
                            Text("Se você deletar sua conta, todas as informações serão perdidas para sempre. Deseja excluir sua conta?",
                              style: TextStyle(
                                fontSize: 18,
                                color: prefix0.primaryText,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                  child: Text("Cancelar",
                                    style: TextStyle(color: primaryText,fontWeight: FontWeight.w700, fontSize: 21),
                                  ),
                                  onPressed: (){
                                  
                                    Navigator.pop(context);
                                  },
                                ),
                                SizedBox(width: 12),
                                FlatButton(
                                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                                    child: Text("Sim",
                                      style: TextStyle(color: primaryText,fontWeight: FontWeight.w700, fontSize: 21),
                                    ),
                                    onPressed: _userAccountBloc.deleteAccount,
                                  )
                              ],
                            )
                          ],
                        );
                      }
                      else if (snapshot.data == LogoutState.LOADING){
                         return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2),
                            ),
                            SizedBox(height: 12),
                            Text("Excluindo sua conta...",
                              style: TextStyle(
                                fontSize: 18,
                                color: prefix0.primaryText,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }
                      else
                      return Container();
                      
                    }
                  )
                ],
              ),
            )
          ),
          
        );
      },
    ); 
  }
  
  Widget saveChanges(UserAccountBloc _bloc){
    return StreamBuilder<SaveState>(
      stream: _bloc.outButton,
      initialData: SaveState.DISABLED,
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
                    color: snapshot.data == SaveState.DISABLED ? Colors.grey : secondaryColor,
                    boxShadow:[
                      BoxShadow(
                        color: snapshot.data == SaveState.DISABLED ? Colors.transparent : secondaryColor.withOpacity(.4),
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
                      onTap: snapshot.data == SaveState.ENABLED
                      ? _bloc.saveSettings : null,
                      child: snapshot.data == SaveState.DISABLED || snapshot.data ==  SaveState.ENABLED ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Concluir",
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700
                            ),
                          )
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

  Widget buildTextInput({String hint, Function(String) changed, Stream<String> stream,
   bool obscure, TextInputType keyboardType, IconData icon}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width * .7,
            height: 60,
            decoration: BoxDecoration(
              color: greyBackground,
              borderRadius: BorderRadius.circular(10)
            ),
            child: StreamBuilder<String>(
              stream: stream,
              builder: (context, snapshot) {
                final controller = TextEditingController(text: snapshot.data);
                controller.selection = TextSelection.fromPosition(
                    new TextPosition(offset: snapshot.data != null ? snapshot.data.length : 0));
                return TextField(
                  onChanged: changed,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(color: hintColor, fontSize: 20),
                    suffixIcon: icon != null ? Icon(icon) : null,
                    
                  ),
                  style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.w600),
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  controller: snapshot.data != null ? controller : null,
                );
              }
            ),
          ),
          ErrorText(stream),
        ],
      ),
    );
  }
}