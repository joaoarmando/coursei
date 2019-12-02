import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/validators/signup_validator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

enum PasswordRequestState{IDLE,LOGIN_SUCCESSFULLY,LOGIN_FAIL, LOADING}
class RecoveryPasswordBloc extends BlocBase with SignUpValidator{

  final _emailController = BehaviorSubject<String>();
  final _recoveryPasswordStateController = BehaviorSubject<PasswordRequestState>.seeded(PasswordRequestState.IDLE);
  final _enabledButtonStateController = BehaviorSubject<bool>();
  final _emailHasSendedBefore = BehaviorSubject<String>();
  List<String> sendedToThisEmails = [];


 
  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<PasswordRequestState> get outRecoveryPasswordState => _recoveryPasswordStateController.stream;
  Stream<bool> get outSubmitValid => _enabledButtonStateController.stream;
  Stream<String> get outSendedBefore => _emailHasSendedBefore.stream;


  
  Function(String) get changeEmail => _emailController.sink.add;

  void verifyEmail(){
    if (_emailController.value.length > 0) {

      int index = getIndex(_emailController.value);
      if (index == -1) {
        _enabledButtonStateController.sink.add(true);
        _emailHasSendedBefore.sink.add("");
      }
      else {
        _emailHasSendedBefore.sink.add("Um email já foi enviado anteriormente, verifique a caixa de entrada/spam");
        _enabledButtonStateController.sink.addError("");
      }

    }
    else {
      _enabledButtonStateController.sink.addError("");
      _emailHasSendedBefore.sink.add("");
    }
  }

  void sendPasswordEmail() async{
    var email = _emailController.value;
    _recoveryPasswordStateController.sink.add(PasswordRequestState.LOADING);
    ParseUser user = ParseUser("","",email);
    ParseResponse apiResponse = await user.requestPasswordReset();
    await Future.delayed(Duration(milliseconds:1500));
    if (apiResponse.success){
      sendedToThisEmails.add(email);
      _recoveryPasswordStateController.sink.add(PasswordRequestState.LOGIN_SUCCESSFULLY);
      _enabledButtonStateController.sink.addError("");
      _emailHasSendedBefore.sink.add("");
    }else {
      _recoveryPasswordStateController.sink.add(PasswordRequestState.LOGIN_FAIL);
    }
    


  }

  int getIndex(String email){
    for ( var i = 0; i < sendedToThisEmails.length; i++){
      if (email == sendedToThisEmails[i]) return i;
    }
    return -1;
  }
  



  @override
  void dispose(){
    _emailController.close();
    _recoveryPasswordStateController.close();
    _enabledButtonStateController.close();
    _emailHasSendedBefore.close();
    super.dispose();
  }
}
