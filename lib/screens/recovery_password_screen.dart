import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/recovery_password_bloc.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class RecoveryPasswordScreen extends StatefulWidget {
  
  @override
  _RecoveryPasswordScreenState createState() => _RecoveryPasswordScreenState();
}

class _RecoveryPasswordScreenState extends State<RecoveryPasswordScreen> {
  RecoveryPasswordBloc _bloc = RecoveryPasswordBloc();
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: prefix0.secondaryColor,
        cursorColor: prefix0.secondaryColor,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 55,
                child: CustomAppBar(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment:Alignment.centerLeft,
                        child: AppBarButton(
                          icon: Icons.close,
                          backgroundColor: prefix0.greyBackground,
                          function: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Recuperar senha",
                          style: TextStyle(color: prefix0.primaryText, fontSize: 21,fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: buildTextInput(
                  hint:"Email",
                  changed: (s){
                    _bloc.changeEmail(s);
                    _bloc.verifyEmail();
                  },
                  stream: _bloc.outEmail,
                  obscure: false,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("Digite seu email acima para recuperar sua senha",
                  style: TextStyle(
                    color: prefix0.tertiaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 50),
              StreamBuilder<PasswordRequestState>(
                stream: _bloc.outRecoveryPasswordState,
                builder: (context, snapshot) {
                  var width = MediaQuery.of(context).size.width * .8;
                  bool isLoading = false;
                  if (snapshot.data == PasswordRequestState.LOADING){
                     width = 55;
                     isLoading = true;
                  }
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                       signUpButton(width, isLoading, _bloc),
                        SizedBox(height: 50),
                        snapshot.data == PasswordRequestState.LOGIN_SUCCESSFULLY ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: FlareActor("assets/check_animation.flr",animation:"check"),
                                ),
                                SizedBox(height: 12),
                                Text("Email enviado com sucesso!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                    color: prefix0.primaryText
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text("Você receberá um email se este endereço de email estiver associado a uma conta, verifique sua caixa de entrada/spam",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: prefix0.secondaryText
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ) : Container()

                      ],
                    ),
                  );
                }
              )

              
            ],
          ),
        ),
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
          width: MediaQuery.of(context).size.width * .8,
          height: 60,
          decoration: BoxDecoration(
            color: prefix0.greyBackground,
            borderRadius: BorderRadius.circular(10)
          ),
          child: TextField(
            onChanged: changed,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: prefix0.hintColor, fontSize: 20),
              suffixIcon: icon != null ? Icon(icon) : null,  
            ),
            style: TextStyle(color: prefix0.primaryText, fontSize: 20, fontWeight: FontWeight.w600),
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

  Widget signUpButton(double width, bool isLoading, RecoveryPasswordBloc _bloc){
    return StreamBuilder<bool>(
      stream: _bloc.outSubmitValid,
      builder: (context, snapshot) {
        return Column(
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
                    color:  snapshot.hasData ? prefix0.secondaryColor : Colors.grey[400]
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 6.0,
                    color: Colors.transparent,
                    shadowColor: Colors.grey[50],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      splashColor: prefix0.secondarySplashColor,
                      onTap: !isLoading && snapshot.hasData  ? (){
                        _bloc.sendPasswordEmail();
                        FocusScope.of(context).unfocus();
                        } : null ,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: !isLoading ? Text(
                              "Recuperar senha",
                              style: TextStyle(
                                color: snapshot.hasData ? prefix0.secondaryText : Colors.grey,
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
            
            StreamBuilder<String>(
              stream: _bloc.outSendedBefore,
              builder: (context, snapshot) {
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(12),
                  child: Text(snapshot.data != null ? "${snapshot.data}" : ""  ,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            )
          ],
        );
      }
    );
  }
}