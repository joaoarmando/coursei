import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/repositories/user_repository.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
enum DialogState{DIALOG_OPTIONS,LOGIN_STATE,LOGIN_SUCCESSFULLY}
class UserBloc extends BlocBase{

  final UserRepository repository;

  final _userController = BehaviorSubject<ParseUser>();
  final _dialogStateController = BehaviorSubject<DialogState>();
  
  ParseUser user;

  Stream get outUser => _userController.stream;
  Stream<DialogState> get outDialogState => _dialogStateController.stream;

  UserBloc(this.repository) {
    checkLogin();
  }

  Future<Null> checkLogin() async {
    user = await repository.checkLogin();
    setUser(user);   
    return;
  }

  void setUser(ParseUser u){
    user = u;
    _userController.add(user);
  }

  bool verifySignIn () => user != null;

  Future<Null> logout() async{
    await user.logout();
    setUser(null);
    return;
  }
  Future<Null> deleteAccount() async{
    if (user != null){
      ParseResponse apiResponse = await user.destroy();
      if (apiResponse.success){
        user.logout();
        setUser(null);
        print(apiResponse.result);
      }
      else print(apiResponse.error.message);

      return;
    }
    return;
  }
  void goToSignIn() async{
    await Future.delayed(Duration(milliseconds: 150));
    _dialogStateController.add(DialogState.LOGIN_STATE);
  }
  void backToDefaultDialog() async{
    await Future.delayed(Duration(milliseconds: 300));
    _dialogStateController.add(DialogState.DIALOG_OPTIONS);
  }
  


@override
void dispose(){
  _userController.close();
  _dialogStateController.close();
  super.dispose();
}

}