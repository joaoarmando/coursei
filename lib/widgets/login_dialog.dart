import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/screens/recovery_password_screen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import '../appColors.dart';
class LoginDialog extends StatefulWidget {
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  LoginBloc _loginBloc = LoginBloc();
  String userName;
  @override
  Widget build(BuildContext context) {
   
    _loginBloc.setUserBloc(_userBloc);
    return StreamBuilder<bool>(
      stream: _loginBloc.outLoginSuccess,
      initialData: false,
      builder: (context, snapshot) {
        if (!snapshot.data){
          //usuario n fez login
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Fazer login",
                style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 25),
              buildTextInput(
                hint: "Email",
                stream: _loginBloc.outEmail,
                changed: _loginBloc.changeEmail,
                obscure: false,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email
              ),
              SizedBox(height: 10),
              buildTextInput(
                hint: "Senha",
                stream: _loginBloc.outPassword,
                changed: _loginBloc.changePassword,
                obscure: true,
                keyboardType: TextInputType.text,
                icon: Icons.lock
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text("Esqueceu sua senha?",
                        style: TextStyle(color: secondaryColor,fontWeight: FontWeight.w600, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: (){
                      final page = RecoveryPasswordScreen();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<LoginState>(
                stream: _loginBloc.outLoginState,
                initialData: LoginState.IDLE,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      snapshot.data == LoginState.IDLE ? FlatButton(
                        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                        child: Text("Cancelar",
                          style: TextStyle(color: primaryText,fontWeight: FontWeight.w700, fontSize: 21),
                        ),
                        onPressed: (){
                          _userBloc.backToDefaultDialog();
                          Navigator.pop(context);
                        },
                      ) : Container(),

                      snapshot.data == LoginState.IDLE || snapshot.data == LoginState.LOGIN_FAIL ? FlatButton(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                              child: Text("Entrar",
                                style: TextStyle(color: secondaryColor,fontWeight: FontWeight.w700, fontSize: 21),
                              ),
                              onPressed: () async{
                                userName = await _loginBloc.signIn();
                              },
                            ) : Container(),
                          
                          snapshot.data == LoginState.LOADING ? Container(
                              height: 25,
                              width:25,
                              margin: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                              child:CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                                strokeWidth: 1.0,
                                )
                            ): Container(),
                          
                    
                      
                    ],
                  );
                }
              )
          
            ],
          );
        } else{
          //LOGIN SUCCESS
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Login efetuado!",
                style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 25),
              Container(
                width: 180,
                height: 180,
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: FlareActor("assets/check_animation.flr",
                  alignment:Alignment.center,
                  fit:BoxFit.contain, 
                  animation: "check",
                  callback: (string) async{
                    await Future.delayed(Duration(seconds: 1));
                    try{
                      if (context != null) Navigator.pop(context);
                    }catch(e){

                    }
                    
                  },
                )
              ),
              Text(
                "Olá $userName, \n Seja bem vindo de volta!",
                style: TextStyle(color: primaryText, fontSize: 18,fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
             
            ],
          );

        }
        
      }
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
          width: MediaQuery.of(context).size.width * .8,
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
        )
      ],
    );
  }
  
}

