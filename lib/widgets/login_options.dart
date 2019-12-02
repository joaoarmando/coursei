import 'package:coursei/appColors.dart';
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/screens/new_account_screen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
class LoginOptions extends StatefulWidget {
  final UserBloc _userBloc;
  LoginOptions(this._userBloc);

  @override
  _LoginOptionsState createState() => _LoginOptionsState();
}

class _LoginOptionsState extends State<LoginOptions> {
  LoginBloc _loginBloc = LoginBloc();
  String userName;
  @override
  Widget build(BuildContext context) {
     _loginBloc.setUserBloc(widget._userBloc);
    return StreamBuilder<DialogState>(
      stream: widget._userBloc.outDialogState,
      initialData: DialogState.DIALOG_OPTIONS,
      builder: (context, snapshot) {
        switch(snapshot.data){
          case DialogState.DIALOG_OPTIONS:
            return buildDialogLoginOptions(context);
          break;
          case DialogState.LOGIN_STATE:
            return buildSignIn();
          break;  
          default:
          return Container();
        }
      }
    );
  }

  Widget _buildDialogButton({@required isPrimaryButton, String text, Function function, @required BuildContext context}){
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

  Widget buildDialogLoginOptions(BuildContext context){
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
        _buildDialogButton(
          isPrimaryButton:true,
          context: context,
          text:"Já tenho uma conta",
          function: widget._userBloc.goToSignIn,
        ),
        SizedBox(height: 15),
        _buildDialogButton(
          isPrimaryButton:false,
          text:"Criar uma conta",
          context: context,
          function: () async{
             await Future.delayed(Duration(milliseconds: 150));
             Navigator.pop(context);
             Navigator.push(context, MaterialPageRoute(builder: (context) => NewAccountScreen()));

          }
        ),
        
    
      ],
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

  Widget buildSignIn(){

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
                          widget._userBloc.backToDefaultDialog();
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
                    Navigator.pop(context);
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
}