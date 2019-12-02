import 'dart:async';

class SignUpValidator{

  final validateName = StreamTransformer<String,String>.fromHandlers(
    handleData: (name,sink){
      
      if (name.length == 0)
        sink.addError("Nome inválido!");
      else if (name.length > 5 && name.split(" ").length > 1 && name.split(" ")[1].length > 0)
        sink.add(name);
      else if (name.length > 0  && name.split(" ").length < 2 || name.split(" ")[1].length == 0)
        sink.addError("Digite seu nome e sobrenome");  

      }
  );
  final validateEmail = StreamTransformer<String,String>.fromHandlers(
    handleData: (email,sink){

      bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
      if (emailValid)
        sink.add(email);
      else
      sink.addError("Insira um email válido");  

    }
  );
  final validatePassword = StreamTransformer<String,String>.fromHandlers(
    handleData: (password,sink){

      if (password.length > 7)
        sink.add(password);
      else
      sink.addError("A senha deve conter ao menos 8 caracteres");  

    }
  );
  

}