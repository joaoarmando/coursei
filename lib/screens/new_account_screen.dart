import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/error_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../appColors.dart';

class NewAccountScreen extends StatefulWidget {
  @override
  _NewAccountScreenState createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  final LoginBloc _loginBloc = LoginBloc();
  Timer timerUserName;
  Timer timerEmail;
  Timer timerPassword;
  Timer timerSecondaryPassword;
  @override
  Widget build(BuildContext context) {
    _loginBloc.setUserBloc(_userBloc);

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: secondaryColor,
        cursorColor: secondaryColor,
       ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              children: <Widget>[
                buildAppBar(context),
                SizedBox(height: 25),
                buildTextInput(
                  hint: "Nome",
                  stream: _loginBloc.outName,
                  changed: (s){
                    if (timerUserName != null) timerUserName.cancel();
                    timerUserName = new Timer(Duration(milliseconds: 500), () => _loginBloc.changeName(s));       
                  },
                  obscure: false,
                  keyboardType: TextInputType.text,
                  icon: Icons.person
                ),
                SizedBox(height: 15),
                buildTextInput(
                  hint: "Email",
                  stream: _loginBloc.outEmail,
                  changed: (s){
                    if (timerEmail != null) timerEmail.cancel();
                    timerEmail = new Timer(Duration(milliseconds: 500), () => _loginBloc.changeEmail(s));
                  },
                  obscure: false,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email
                ),
                SizedBox(height: 15),
                buildTextInput(
                  hint: "Senha",
                  stream: _loginBloc.outPassword,
                  changed: (s){
                    if (timerPassword != null) timerPassword.cancel();
                    timerPassword = new Timer(Duration(milliseconds: 500), () => _loginBloc.changePassword(s));
                  },
                  obscure: true,
                  keyboardType: TextInputType.text,
                  icon: Icons.lock
                ),
                SizedBox(height: 15),
                buildTextInput(
                  hint: "Confirmar senha",
                  stream: _loginBloc.outSecondaryPassword,
                  changed: (s){
                    if (timerSecondaryPassword != null) timerSecondaryPassword.cancel();
                    timerSecondaryPassword = new Timer(Duration(milliseconds: 500), () => _loginBloc.changeSecondaryPassword(s));
                  },
                  obscure: true,
                  keyboardType: TextInputType.text,
                  icon: Icons.lock
                ),
                SizedBox(height: 19),
                buildSignUpButton(_loginBloc)
              ],
            ),
          ),
        )
      ),
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
                _userBloc.backToDefaultDialog();
                Navigator.pop(context);
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Criar conta",
              style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
  Widget buildTextInput({String hint, Function(String) changed, Stream<String> stream,
   bool obscure, TextInputType keyboardType, IconData icon}){
    return Column(
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
          child: TextField(
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
          ),
        ),
        ErrorText(stream),
       /* remover isso se tudo funcionar 
        StreamBuilder<String>(
          stream: stream,
          builder: (context, snapshot) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(snapshot.hasError ? "${snapshot.error}" : "",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14
                ),
              ),
            );
          }
        ) */
      ],
    );
  }
  Widget buildSignUpButton(LoginBloc _loginBloc){
    double width;
    return StreamBuilder<LoginState>(
      stream: _loginBloc.outLoginState,
      initialData: LoginState.IDLE,
      builder: (context, snapshot) {
        bool isLoading = snapshot.data == LoginState.LOADING;
        width = snapshot.data == LoginState.IDLE ? MediaQuery.of(context).size.width * .7 : 55;
        return  snapshot.data == LoginState.LOGIN_SUCCESSFULLY ? 
          Column(
            children: <Widget>[
              Container(
                width: 180,
                height: 180,
                child: FlareActor("assets/check_animation.flr",
                  alignment:Alignment.center,
                  fit:BoxFit.contain, 
                  animation: "check",
                  callback: (string) async{
                    await Future.delayed(Duration(milliseconds: 500));
                    Navigator.pop(context);
                  },
                )
              ),
              Text("Conta criada com sucesso!",
                style: TextStyle(color: secondaryText, fontSize: 21, fontWeight: FontWeight.w600),
              )
            ],
          ) : signUpButton(width, isLoading,_loginBloc);
      }
    );
  }

  Widget signUpButton(double width, bool isLoading, LoginBloc _loginBloc){
    return StreamBuilder<bool>(
      stream: _loginBloc.outSubmitValid,
      builder: (context, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              width: width,
              height: 55,
              duration: Duration(milliseconds: 300),
              child: Material(
                shadowColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)
                  ),
                elevation: 6.0,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color:  snapshot.hasData ? secondaryColor : Colors.grey[400]
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 6.0,
                    color: Colors.transparent,
                    shadowColor: Colors.grey[50],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      splashColor: secondarySplashColor,
                      onTap: !isLoading && snapshot.hasData  ? _loginBloc.signUp : null ,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: !isLoading ? Text(
                              "Criar conta",
                              style: TextStyle(
                                color: snapshot.hasData ? secondaryText : Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            ) : Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(12),
                              child: Container(
                                height: 25,
                                width:25,
                                child:CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(prefix0.tertiaryText),
                                  strokeWidth: 1.0,
                                  )
                              )
                            )
                          )
                        ],
                      ),
                    ),
                  ),
              ),
          ),
            ),
          ],
        );
      }
    );
  }
  
}

