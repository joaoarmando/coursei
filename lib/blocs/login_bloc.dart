import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/validators/signup_validator.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum LoginState{IDLE,LOGIN_SUCCESSFULLY,LOGIN_FAIL, LOADING}
class LoginBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;

  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _secondaryPasswordController = BehaviorSubject<String>();
  final _loginStateController = BehaviorSubject<LoginState>();
  final _loginSuccessController = BehaviorSubject<bool>();


  Stream<String> get outName => _nameController.stream.transform(validateName);
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<String> get outSecondaryPassword => _secondaryPasswordController.stream.transform(validatePassword);
  Stream<LoginState> get outLoginState => _loginStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;

  Stream<bool> get outSubmitValid => Rx.combineLatest4(
      outName, outEmail, outPassword, outSecondaryPassword, (a,b,c,d) => true
    );

  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  } 
  

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeSecondaryPassword => _secondaryPasswordController.sink.add;

  
  Future<String> signIn() async{
    
    final username = _emailController.value;
    final password = _passwordController.value;
    if (username == null || username.trim().length == 0 ||  password == null || password.trim().length == 0) {
      _invalidCredentials();
      return null;
    }
    _loginStateController.sink.add(LoginState.LOADING);
    var user = ParseUser(username, password,"");
    var response = await user.login();
    await Future.delayed(Duration(seconds: 1));
    if (response.success){
      user = response.result;
      print("User: ${response.result.toString()}");
      await getSavedCoursesCount(user);
      _userBloc.setUser(user);
      _loginStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
      _loginSuccessController.sink.add(true);
      String name = user.get("name");
      if (name != null) name = user.get("name").split(" ")[0];
      return (name ?? "");
    }
    else if (response.error.code == 101)
      _invalidCredentials();

    else{
      user = null;
      _userBloc.setUser(user);
      await Future.delayed(Duration(seconds: 1));
      //_loginLoadingController.add(false);  
    }

    return null;
       
    
  }
  Future<Null> getSavedCoursesCount(ParseUser user) async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int newValue = 0;
     if (user.get("notificationsBadge") != null){
          if (user.get("notificationsBadge")  >= 0) newValue =  user.get("notificationsBadge");
     }
     prefs.setInt('savedCoursesCount', newValue);
     return;
  }
 
  void _invalidCredentials(){
    _passwordController.sink.addError("Email ou senha incorretos");
    _loginStateController.sink.add(LoginState.IDLE);
  }
  Future<bool> signUp() async{
  final name = _nameController.value;
  final email = _emailController.value;
  final password = _passwordController.value;
  final secondaryPassword = _secondaryPasswordController.value;
  _loginStateController.sink.add(LoginState.LOADING);
  if ( password != secondaryPassword){
      await Future.delayed(Duration(milliseconds: 600));
      _secondaryPasswordController.sink.addError("As senhas não coincidem");
      _loginStateController.sink.add(LoginState.IDLE);
      return false;
  }

  var user = ParseUser(_randomString(usernameLength: 10), password, email)
          ..set("name", name);
  var response = await user.signUp();
  if (response.success){
    user = response.result; 
    _userBloc.setUser(user);
    _userBloc.verifySignIn();
    await Future.delayed(Duration(milliseconds: 300));
    _loginStateController.sink.add(LoginState.LOGIN_SUCCESSFULLY);
    return true;
  }
  else {
    if (response.error.code == 203){
      _emailController.sink.addError("Este email já esta em uso");
    }
    await Future.delayed(Duration(milliseconds: 300));
    _loginStateController.sink.add(LoginState.IDLE);
    return false;
  } 
    
}
  
  String _randomString({int usernameLength}) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < usernameLength; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}


  @override
  void dispose(){
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _loginStateController.close();
    _loginSuccessController.close();
    _secondaryPasswordController.close();
    super.dispose();
  }
}
