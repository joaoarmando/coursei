import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/validators/signup_validator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum LogoutState{IDLE,LOGOUT_SUCCESSFULLY, LOADING}
enum SaveState{DISABLED,ENABLED, LOADING, SUCCSSEFULLY}
class UserAccountBloc extends BlocBase  with SignUpValidator{
   UserBloc _userBloc;
   ParseUser user;

   String initialUserName;
   String initialEmail;

  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _logoutStateController = BehaviorSubject<LogoutState>.seeded(LogoutState.IDLE);
  final _loginSuccessController = BehaviorSubject<bool>();
  final _userInfoLoadingController = BehaviorSubject<bool>();
  final _saveChangesState = BehaviorSubject<SaveState>.seeded(SaveState.DISABLED);




  Stream<String> get outName => _nameController.stream.transform(validateName);
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword => _passwordController.stream.transform(validatePassword);
  Stream<LogoutState> get outLogoutState => _logoutStateController.stream;
  Stream<bool> get outLoginSuccess => _loginSuccessController.stream;
  Stream<bool> get outLoading => _userInfoLoadingController.stream;
  Stream<SaveState> get outButton => _saveChangesState.stream;

  void validateInfo(){
   
    bool validFields = validateFields();
    if (validFields){
        _saveChangesState.sink.add(SaveState.ENABLED);
    }else _saveChangesState.sink.add(SaveState.DISABLED);
   
  }
  bool validateFields(){
    var name = _nameController.value;
    var email = _emailController.value;
    var password = _passwordController.value;

    bool validName = checkName(name);
    bool validEmail = checkEmail(email);
    bool validPassword = checkPassword(password);

    if (validName && validEmail && validPassword) return true;
    else return false;
  }
  bool checkName(String name){
      
      if (name.length == 0)
        return false;
      else if (name.length > 5 && name.split(" ").length > 1 && name.split(" ")[1].length > 0)
        return true;
      else if (name.length > 0  && name.split(" ").length < 2 || name.split(" ")[1].length == 0)
        return false;

      else return true;   
  }

  bool checkEmail(String email){
    if (email == null) return true;

      bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
      if (emailValid) return true;
      else return false;

  }

  bool checkPassword(String password){

    if(password == null) return true;
    else if (password.length > 7) return true;
    else return false;  

  }
  
  

  void setUserBloc(UserBloc bloc){
    _userBloc = bloc;
  } 
  

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  void getUser() async{
    user = await ParseUser.currentUser();
    if (user != null){
      initialUserName = user.get("name");
      initialEmail = user.get("email");
      _nameController.sink.add(initialUserName);
      _emailController.sink.add(initialEmail);
      _userInfoLoadingController.sink.add(false);
    }
  }

  void saveSettings() async{
    if (_saveChangesState.value == SaveState.ENABLED){
      _saveChangesState.sink.add(SaveState.LOADING);
      await Future.delayed(Duration(milliseconds:500)); // ESPERA 500 MILI PRA SE CERTIFICAR DE QUE OS DADOS CHEGARM ATUALIZADOS
      if (!validateFields()) return;
      if (_emailController.value.length == 0) {
        _emailController.sink.addError("Insira um email válido");
        _saveChangesState.add(SaveState.DISABLED);
        return;
      }
       var name = _nameController.value;
       var email = _emailController.value;
       var password = _passwordController.value;
       if (name != user.get("name")) user.set("name", name.trim());
       if (email != user.get("email")) user.set("email", email.trim());
       if (password != null && password.length > 0) user.set("password",password);
       ParseResponse apiResponse = await user.save();

       if (apiResponse.success){
          _saveChangesState.sink.add(SaveState.SUCCSSEFULLY);
       }
       else {
         if (apiResponse.error.code == 203) {
           _emailController.sink.addError("Este endereço de email já esta em uso");
           _saveChangesState.add(SaveState.DISABLED);
         }
          print(apiResponse.error.code);
       }
    }
  }


  void logout() async{
    _logoutStateController.sink.add(LogoutState.LOADING);
    await _userBloc.logout();
    await deleteSavedCoursesCount();
    await Future.delayed(Duration(seconds:1));
    _logoutStateController.sink.add(LogoutState.LOGOUT_SUCCESSFULLY);
    //_saveChangesState.sink.add(SaveState.SUCCSSEFULLY);
  }

  void deleteAccount() async{
    _logoutStateController.sink.add(LogoutState.LOADING);
    await _userBloc.deleteAccount();
    await deleteSavedCoursesCount();
    await Future.delayed(Duration(seconds:1));
    _logoutStateController.sink.add(LogoutState.LOGOUT_SUCCESSFULLY);
  }

  Future<Null> deleteSavedCoursesCount() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setInt('savedCoursesCount', 0);
     return;
  }


  @override
  void dispose(){
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _logoutStateController.close();
    _loginSuccessController.close();
    _userInfoLoadingController.close();
    _saveChangesState.close();
    super.dispose();
  }
}
